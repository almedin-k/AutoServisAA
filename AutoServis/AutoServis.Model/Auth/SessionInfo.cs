namespace AutoServis.Model.Auth;
public class SessionInfo
{
    public int SessionId { get; set; }
    public string RefreshToken { get; set; } = string.Empty;
    public DateTime RefreshTokenExpiresAt { get; set; }
}
