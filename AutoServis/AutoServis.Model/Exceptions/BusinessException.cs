namespace AutoServis.Model.Exceptions;

// A business rule was violated. Mapped to HTTP 400 with a user-facing message.
public class BusinessException : Exception
{
    public BusinessException(string message) : base(message) {}
}
