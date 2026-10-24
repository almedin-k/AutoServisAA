using AutoServis.Model.Auth;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;

namespace AutoServis.Services.Auth;

public interface IAuthService
{
    Task<AuthSession> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<AuthSession> RefreshAsync(string refreshToken, CancellationToken cancellationToken = default);
    Task LogoutAsync(int sessionId, CancellationToken cancellationToken = default);
    Task<bool> IsSessionActiveAsync(int sessionId, CancellationToken cancellationToken = default);
    Task<CurrentUserResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
}
