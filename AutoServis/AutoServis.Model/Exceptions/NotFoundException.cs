namespace AutoServis.Model.Exceptions;

// The requested record does not exist. Mapped to HTTP 404.
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message)
    {
    }

    public NotFoundException(string entityName, int id)
        : base("Traženi zapis nije pronađen.")
    {
        EntityName = entityName;
        EntityId = id;
    }
    public string? EntityName { get; }

    public int? EntityId { get; }
}
