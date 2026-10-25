namespace AutoServis.Model.Exceptions;

// The requested record does not exist. Mapped to HTTP 404.
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message) {}

    public NotFoundException(string entityName, int id)
        : base($"{entityName} with id {id} was not found.")
    {
    }
}
