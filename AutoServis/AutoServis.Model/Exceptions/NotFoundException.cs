namespace AutoServis.Model.Exceptions;

/// <summary>
/// The requested record does not exist. Mapped to HTTP 404.
/// </summary>
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message)
    {
    }

    public NotFoundException(string entityName, int id)
        : base($"{entityName} with id {id} was not found.")
    {
    }
}
