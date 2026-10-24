namespace AutoServis.Model.Auth;

/// <summary>
/// A server-side session. The session id is embedded in the access token ("sid" claim)
/// so that logging out invalidates the token on the server.
/// </summary>
public class SessionInfo
{
    public int SessionId { get; set; }
    public string RefreshToken { get; set; } = string.Empty;
    public DateTime RefreshTokenExpiresAt { get; set; }
}
