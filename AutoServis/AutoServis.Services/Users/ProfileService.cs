using AutoServis.Common.Services;
using AutoServis.Model.Constants;
using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Services.Auth;
using AutoServis.Services.Catalog;
using AutoServis.Services.Database;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace AutoServis.Services.Users;
public class ProfileService : IProfileService
{
    private readonly AutoServisDbContext _dbContext;
    private readonly IAuthenticatedUserAccessor _currentUser;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IAuthService _authService;
    private readonly IValidator<UpdateProfileRequest> _updateValidator;
    private readonly IValidator<ChangePasswordRequest> _passwordValidator;
    private readonly ILogger<ProfileService> _logger;
    public ProfileService(
        AutoServisDbContext dbContext,
        IAuthenticatedUserAccessor currentUser,
        IPasswordHasher passwordHasher,
        IAuthService authService,
        IValidator<UpdateProfileRequest> updateValidator,
        IValidator<ChangePasswordRequest> passwordValidator,
        ILogger<ProfileService> logger)
    {
        _dbContext = dbContext;
        _currentUser = currentUser;
        _passwordHasher = passwordHasher;
        _authService = authService;
        _updateValidator = updateValidator;
        _passwordValidator = passwordValidator;
        _logger = logger;
    }

    public async Task<ProfileResponse> GetAsync(CancellationToken cancellationToken = default)
    {
        var userId = GetUserId();
        var profile = await _dbContext.Users
            .AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => new ProfileResponse
            {
                Id = u.Id,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Username = u.Username,
                Email = u.Email,
                PhoneNumber = u.PhoneNumber,
                CityId = u.CityId,
                CityName = u.City != null ? u.City.Name : null,
                HasProfileImage = u.ProfileImage != null,
                CreatedAt = u.CreatedAt
            })
            .FirstOrDefaultAsync(cancellationToken);
        return profile ?? throw new NotFoundException("User", userId);
    }

    public async Task<ProfileResponse> UpdateAsync(UpdateProfileRequest request, CancellationToken cancellationToken = default)
    {
        await _updateValidator.ValidateAndThrowAsync(request, cancellationToken);
        var userId = GetUserId();
        var email = request.Email.Trim();
        if (await _dbContext.Users.AnyAsync(u => u.Email == email && u.Id != userId, cancellationToken))
        {
            throw FieldError(nameof(request.Email), "Račun s ovom e-mail adresom već postoji.");
        }
        if (request.CityId.HasValue
            && !await _dbContext.Cities.AnyAsync(c => c.Id == request.CityId.Value, cancellationToken))
        {
            throw FieldError(nameof(request.CityId), "Odabrani grad ne postoji.");
        }
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new NotFoundException("User", userId);
        user.FirstName = request.FirstName.Trim();
        user.LastName = request.LastName.Trim();
        user.Email = email;
        user.PhoneNumber = string.IsNullOrWhiteSpace(request.PhoneNumber) ? null : request.PhoneNumber.Trim();
        user.CityId = request.CityId;
        await _dbContext.SaveChangesAsync(cancellationToken);
        return await GetAsync(cancellationToken);
    }

    public async Task ChangePasswordAsync(ChangePasswordRequest request, CancellationToken cancellationToken = default)
    {
        await _passwordValidator.ValidateAndThrowAsync(request, cancellationToken);
        var userId = GetUserId();
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new NotFoundException("User", userId);
        if (!_passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
        {
            throw FieldError(nameof(request.CurrentPassword), "Trenutna lozinka nije ispravna.");
        }
        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        await _dbContext.SaveChangesAsync(cancellationToken);
        // The old password must not stay signed in on another device.
        await _authService.RevokeOtherSessionsAsync(userId, _currentUser.GetSessionId(), cancellationToken);
        _logger.LogInformation("User {UserId} changed the password", userId);
    }

    public async Task<ProfileImageResponse> GetImageAsync(CancellationToken cancellationToken = default)
    {
        var userId = GetUserId();
        var image = await _dbContext.Users
            .AsNoTracking()
            .Where(u => u.Id == userId && u.ProfileImage != null)
            .Select(u => new ProfileImageResponse
            {
                Data = u.ProfileImage!,
                ContentType = u.ProfileImageContentType ?? "image/jpeg"
            })
            .FirstOrDefaultAsync(cancellationToken);
        return image ?? throw new NotFoundException("Nemate postavljenu sliku profila.");
    }

    public async Task SetImageAsync(byte[] data, CancellationToken cancellationToken = default)
    {
        if (data.Length == 0)
        {
            throw new BusinessException("Datoteka sa slikom je prazna.");
        }
        if (data.Length > ProfileImageRules.MaxBytes)
        {
            throw new BusinessException(
                $"Slika je prevelika. Maksimalna veličina je {ProfileImageRules.MaxBytes / (1024 * 1024)} MB.");
        }
        // The content type sent by the client is not trusted, the format is read from the file itself.
        var contentType = ImageSignature.Detect(data)
            ?? throw new BusinessException($"Dozvoljene su samo slike u formatu {ProfileImageRules.AllowedFormatsDescription}.");
        var userId = GetUserId();
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new NotFoundException("User", userId);
        user.ProfileImage = data;
        user.ProfileImageContentType = contentType;
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteImageAsync(CancellationToken cancellationToken = default)
    {
        var userId = GetUserId();
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken)
            ?? throw new NotFoundException("User", userId);
        user.ProfileImage = null;
        user.ProfileImageContentType = null;
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    private int GetUserId()
    {
        return _currentUser.GetUserId()
            ?? throw new AuthenticationFailedException("Vaša sesija je istekla. Prijavite se ponovo.");
    }

    private static ValidationException FieldError(string propertyName, string message)
        => new(new[] { new ValidationFailure(propertyName, message) });
}