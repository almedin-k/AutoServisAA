using System.Security.Claims;
using AutoServis.Services;

namespace AutoServis.WebAPI.Services;

public class HttpAuthenticatedUserAccessor : IAuthenticatedUserAccessor
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public HttpAuthenticatedUserAccessor(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ClaimsPrincipal? Principal => _httpContextAccessor.HttpContext?.User;

    public int? GetUserId() => ReadIntClaim(JwtClaimNames.Subject);

    public int? GetSessionId() => ReadIntClaim(JwtClaimNames.SessionId);

    public bool IsInRole(string role) => Principal?.IsInRole(role) ?? false;

    private int? ReadIntClaim(string claimType)
    {
        var value = Principal?.FindFirstValue(claimType);
        return int.TryParse(value, out var number) ? number : null;
    }
}
