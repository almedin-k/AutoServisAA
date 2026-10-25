using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AutoServis.Model.Auth;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Services.Auth;
using Microsoft.IdentityModel.Tokens;

namespace AutoServis.WebAPI.Services;

// Builds signed access tokens for authenticated sessions. Credentials and sessions are handled by <see cref="IAuthService"/>.
public class AccessManager : IAccessManager
{
    private readonly IAuthService _authService;
    private readonly JwtSettings _jwt;

    public AccessManager(IAuthService authService, AppSettings settings)
    {
        _authService = authService;
        _jwt = settings.Jwt;
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        var session = await _authService.LoginAsync(request, cancellationToken);
        return BuildResponse(session);
    }

    public async Task<AuthResponse> RefreshAsync(RefreshTokenRequest request, CancellationToken cancellationToken = default)
    {
        var session = await _authService.RefreshAsync(request.RefreshToken, cancellationToken);
        return BuildResponse(session);
    }

    private AuthResponse BuildResponse(AuthSession session)
    {
        var expiresAt = DateTime.UtcNow.AddMinutes(_jwt.AccessTokenMinutes);

        var claims = new List<Claim>
        {
            new(JwtClaimNames.Subject, session.User.Id.ToString()),
            new(JwtClaimNames.UniqueName, session.User.Username),
            new(JwtClaimNames.SessionId, session.Session.SessionId.ToString()),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };
        claims.AddRange(session.User.Roles.Select(role => new Claim(JwtClaimNames.Role, role)));

        var descriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = expiresAt,
            Issuer = _jwt.Issuer,
            Audience = _jwt.Audience,
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwt.SecretKey)),
                SecurityAlgorithms.HmacSha256)
        };

        var handler = new JwtSecurityTokenHandler();
        var accessToken = handler.WriteToken(handler.CreateToken(descriptor));

        return new AuthResponse
        {
            AccessToken = accessToken,
            AccessTokenExpiresAt = expiresAt,
            RefreshToken = session.Session.RefreshToken,
            User = new CurrentUserResponse
            {
                Id = session.User.Id,
                FirstName = session.User.FirstName,
                LastName = session.User.LastName,
                Username = session.User.Username,
                Email = session.User.Email,
                Roles = session.User.Roles
            }
        };
    }
}
