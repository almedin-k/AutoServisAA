using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Services;
using AutoServis.Services.Auth;
using AutoServis.WebAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

[ApiController]
[Route("[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAccessManager _accessManager;
    private readonly IAuthService _authService;
    private readonly IAuthenticatedUserAccessor _userAccessor;

    public AuthController(
        IAccessManager accessManager,
        IAuthService authService,
        IAuthenticatedUserAccessor userAccessor)
    {
        _accessManager = accessManager;
        _authService = authService;
        _userAccessor = userAccessor;
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login(
        [FromBody] LoginRequest request, CancellationToken cancellationToken)
    {
        return Ok(await _accessManager.LoginAsync(request, cancellationToken));
    }

    [AllowAnonymous]
    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponse>> Refresh(
        [FromBody] RefreshTokenRequest request, CancellationToken cancellationToken)
    {
        return Ok(await _accessManager.RefreshAsync(request, cancellationToken));
    }

    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<ActionResult<CurrentUserResponse>> Register(
        [FromBody] RegisterRequest request, CancellationToken cancellationToken)
    {
        var user = await _authService.RegisterAsync(request, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, user);
    }

    /// <summary>Revokes the current session on the server, so the access token stops working immediately.</summary>
    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(CancellationToken cancellationToken)
    {
        var sessionId = _userAccessor.GetSessionId()
            ?? throw new AuthenticationFailedException("Your session has expired. Please sign in again.");

        await _authService.LogoutAsync(sessionId, cancellationToken);
        return NoContent();
    }
}
