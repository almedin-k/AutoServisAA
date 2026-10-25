namespace AutoServis.Model.Responses;

public class ServiceResponse
{
    public int Id { get; set; }
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMinutes { get; set; }
    public int WarrantyMonths { get; set; }
    public bool IsActive { get; set; }

    public bool HasImage { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public List<ServicePartResponse> RequiredParts { get; set; } = new();
}

public class ServicePartResponse
{
    public int PartId { get; set; }
    public string PartName { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; }
}
