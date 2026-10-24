namespace AutoServis.Services.Database.Entities;

/// <summary>
/// Parts that are usually needed for a service (shown to the client as "Required parts").
/// </summary>
public class ServicePart
{
    public int ServiceId { get; set; }
    public Service Service { get; set; } = null!;

    public int PartId { get; set; }
    public Part Part { get; set; } = null!;

    public int Quantity { get; set; }
}
