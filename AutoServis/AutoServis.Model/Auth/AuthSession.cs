namespace AutoServis.Model.Auth;

public class AuthSession
{
    public AuthenticatedUser User { get; set; } = new();
    public SessionInfo Session { get; set; } = new();
}
