namespace AutoServis.Services.Database.Entities;

public class Service
{
    public int Id { get; set; }

    public int CategoryId { get; set; }
    public ServiceCategory Category { get; set; } = null!;

    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public decimal Price { get; set; }

    public int DurationMinutes { get; set; }
    public int WarrantyMonths { get; set; }
    public bool IsActive { get; set; }

    public bool HasImage { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public ServiceImage? Image { get; set; }

    public ICollection<ServicePart> ServiceParts { get; set; } = null!;
}
