using AutoServis.Model.Requests;
using AutoServis.Model.Responses;

namespace AutoServis.WebAPI.Services;

public interface IAccessManager
{
    Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> RefreshAsync(RefreshTokenRequest request, CancellationToken cancellationToken = default);
}
