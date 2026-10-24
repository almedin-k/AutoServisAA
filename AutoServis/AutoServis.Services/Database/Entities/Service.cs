namespace AutoServis.Services.Database.Entities;

/// <summary>
/// A service offered by the workshop (for example "Complete diagnostics").
/// </summary>
public class Service
{
    public int Id { get; set; }

    public int CategoryId { get; set; }
    public ServiceCategory Category { get; set; } = null!;

    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    /// <summary>Price in KM. The server is the only source of truth for prices.</summary>
    public decimal Price { get; set; }

    public int DurationMinutes { get; set; }
    public int WarrantyMonths { get; set; }
    public bool IsActive { get; set; }

    /// <summary>True when a row exists in ServiceImages. Lets list endpoints skip the image blob.</summary>
    public bool HasImage { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public ServiceImage? Image { get; set; }
    public ICollection<ServicePart> ServiceParts { get; set; } = new List<ServicePart>();
}
