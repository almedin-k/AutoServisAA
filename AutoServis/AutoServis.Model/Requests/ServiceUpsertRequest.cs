namespace AutoServis.Model.Requests;

public class ServiceUpsertRequest
{
    public int CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public decimal Price { get; set; }

    public int DurationMinutes { get; set; }
    public int WarrantyMonths { get; set; }
    public bool IsActive { get; set; } = true;

    public List<ServicePartRequest> RequiredParts { get; set; } = new();
}

public class ServicePartRequest
{
    public int PartId { get; set; }
    public int Quantity { get; set; } = 1;
}
