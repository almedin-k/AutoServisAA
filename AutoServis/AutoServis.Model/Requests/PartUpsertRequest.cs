namespace AutoServis.Model.Requests;

public class PartUpsertRequest
{
    public string Name { get; set; } = string.Empty;
    public string? Sku { get; set; }

    public decimal UnitPrice { get; set; }

    public bool IsActive { get; set; } = true;
}
