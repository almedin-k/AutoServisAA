namespace AutoServis.Model.Exceptions;

/// <summary>
/// A business rule was violated. Mapped to HTTP 400 with a user-facing message.
/// </summary>
public class BusinessException : Exception
{
    public BusinessException(string message) : base(message)
    {
    }
}
