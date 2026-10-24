namespace AutoServis.Model.Exceptions;

/// <summary>
/// Credentials or session are not valid. Mapped to HTTP 401.
/// </summary>
public class AuthenticationFailedException : Exception
{
    public AuthenticationFailedException(string message) : base(message)
    {
    }
}
