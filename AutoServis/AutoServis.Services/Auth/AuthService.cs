using AutoServis.Common.Services;
using AutoServis.Model.Auth;
using AutoServis.Model.Constants;
using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Services.Configuration;
using AutoServis.Services.Database;
using AutoServis.Services.Database.Entities;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;

namespace AutoServis.Services.Auth;

public class AuthService : IAuthService
{
    private const string InvalidCredentialsMessage = "Invalid username or password.";
    private const string SessionExpiredMessage = "Your session has expired. Please sign in again.";
    private static readonly TimeSpan SessionCacheDuration = TimeSpan.FromSeconds(30);

    private readonly AutoServisDbContext _dbContext;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ISecureTokenGenerator _tokenGenerator;
    private readonly IMemoryCache _cache;
    private readonly SessionSettings _sessionSettings;
    private readonly IValidator<RegisterRequest> _registerValidator;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        AutoServisDbContext dbContext,
        IPasswordHasher passwordHasher,
        ISecureTokenGenerator tokenGenerator,
        IMemoryCache cache,
        SessionSettings sessionSettings,
        IValidator<RegisterRequest> registerValidator,
        ILogger<AuthService> logger)
    {
        _dbContext = dbContext;
        _passwordHasher = passwordHasher;
        _tokenGenerator = tokenGenerator;
        _cache = cache;
        _sessionSettings = sessionSettings;
        _registerValidator = registerValidator;
        _logger = logger;
    }

    public async Task<AuthSession> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrEmpty(request.Password))
        {
            throw new AuthenticationFailedException(InvalidCredentialsMessage);
        }

        var user = await _dbContext.Users
            .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Username == request.Username, cancellationToken);

        if (user is null || !user.IsActive || !_passwordHasher.Verify(request.Password, user.PasswordHash))
        {
            _logger.LogWarning("Failed sign-in attempt for username {Username}", request.Username);
            throw new AuthenticationFailedException(InvalidCredentialsMessage);
        }

        var now = DateTime.UtcNow;
        user.LastLoginAt = now;

        var (refreshToken, rawToken) = CreateRefreshToken(user.Id, now);
        _dbContext.RefreshTokens.Add(refreshToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("User {UserId} signed in (session {SessionId})", user.Id, refreshToken.Id);

        return BuildSession(user, refreshToken, rawToken);
    }

    public async Task<AuthSession> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(refreshToken))
        {
            throw new AuthenticationFailedException(SessionExpiredMessage);
        }

        var tokenHash = _tokenGenerator.Hash(refreshToken);
        var existing = await _dbContext.RefreshTokens
            .Include(t => t.User).ThenInclude(u => u.UserRoles).ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(t => t.TokenHash == tokenHash, cancellationToken);

        var now = DateTime.UtcNow;
        if (existing is null || existing.RevokedAt is not null || existing.ExpiresAt <= now || !existing.User.IsActive)
        {
            throw new AuthenticationFailedException(SessionExpiredMessage);
        }

        existing.RevokedAt = now;
        var (newToken, rawToken) = CreateRefreshToken(existing.UserId, now);
        _dbContext.RefreshTokens.Add(newToken);
        await _dbContext.SaveChangesAsync(cancellationToken);

        _cache.Remove(SessionCacheKey(existing.Id));

        return BuildSession(existing.User, newToken, rawToken);
    }

    public async Task LogoutAsync(int sessionId, CancellationToken cancellationToken = default)
    {
        var session = await _dbContext.RefreshTokens
            .FirstOrDefaultAsync(t => t.Id == sessionId && t.RevokedAt == null, cancellationToken);

        if (session is not null)
        {
            session.RevokedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        _cache.Remove(SessionCacheKey(sessionId));
        _logger.LogInformation("Session {SessionId} was revoked", sessionId);
    }

    public async Task<bool> IsSessionActiveAsync(int sessionId, CancellationToken cancellationToken = default)
    {
        var isActive = await _cache.GetOrCreateAsync(SessionCacheKey(sessionId), async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = SessionCacheDuration;

            var now = DateTime.UtcNow;
            return await _dbContext.RefreshTokens.AnyAsync(
                t => t.Id == sessionId && t.RevokedAt == null && t.ExpiresAt > now && t.User.IsActive,
                cancellationToken);
        });

        return isActive;
    }

    public async Task<CurrentUserResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        await _registerValidator.ValidateAndThrowAsync(request, cancellationToken);

        var username = request.Username.Trim();
        var email = request.Email.Trim();

        if (await _dbContext.Users.AnyAsync(u => u.Username == username, cancellationToken))
        {
            throw new BusinessException("This username is already taken. Please choose another one.");
        }

        if (await _dbContext.Users.AnyAsync(u => u.Email == email, cancellationToken))
        {
            throw new BusinessException("An account with this email address already exists.");
        }

        if (request.CityId.HasValue && !await _dbContext.Cities.AnyAsync(c => c.Id == request.CityId.Value, cancellationToken))
        {
            throw new BusinessException("The selected city does not exist.");
        }

        var clientRole = await _dbContext.Roles.FirstAsync(r => r.Name == Roles.Client, cancellationToken);

        var user = new User
        {
            FirstName = request.FirstName.Trim(),
            LastName = request.LastName.Trim(),
            Username = username,
            Email = email,
            PhoneNumber = string.IsNullOrWhiteSpace(request.PhoneNumber) ? null : request.PhoneNumber.Trim(),
            CityId = request.CityId,
            PasswordHash = _passwordHasher.Hash(request.Password),
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UserRoles = new List<UserRole> { new() { RoleId = clientRole.Id } }
        };

        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("New client registered with id {UserId}", user.Id);

        return new CurrentUserResponse
        {
            Id = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Username = user.Username,
            Email = user.Email,
            Roles = new List<string> { clientRole.Name }
        };
    }

    private (RefreshToken Entity, string RawToken) CreateRefreshToken(int userId, DateTime now)
    {
        var rawToken = _tokenGenerator.CreateToken();
        var entity = new RefreshToken
        {
            UserId = userId,
            TokenHash = _tokenGenerator.Hash(rawToken),
            CreatedAt = now,
            ExpiresAt = now.AddDays(_sessionSettings.RefreshTokenDays)
        };

        return (entity, rawToken);
    }

    private static AuthSession BuildSession(User user, RefreshToken refreshToken, string rawToken)
    {
        return new AuthSession
        {
            User = new AuthenticatedUser
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Username = user.Username,
                Email = user.Email,
                Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList()
            },
            Session = new SessionInfo
            {
                SessionId = refreshToken.Id,
                RefreshToken = rawToken,
                RefreshTokenExpiresAt = refreshToken.ExpiresAt
            }
        };
    }

    private static string SessionCacheKey(int sessionId) => $"session:{sessionId}";
}
