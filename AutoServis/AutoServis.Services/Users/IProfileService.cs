using AutoServis.Model.Requests;
using AutoServis.Model.Responses;

namespace AutoServis.Services.Users;

// The account of the signed-in user: data, profile picture and password
public interface IProfileService
{
    Task<ProfileResponse> GetAsync(CancellationToken cancellationToken = default);
    Task<ProfileResponse> UpdateAsync(UpdateProfileRequest request, CancellationToken cancellationToken = default);
    Task ChangePasswordAsync(ChangePasswordRequest request, CancellationToken cancellationToken = default);
    Task<ProfileImageResponse> GetImageAsync(CancellationToken cancellationToken = default);
    Task SetImageAsync(byte[] data, CancellationToken cancellationToken = default);
    Task DeleteImageAsync(CancellationToken cancellationToken = default);
}