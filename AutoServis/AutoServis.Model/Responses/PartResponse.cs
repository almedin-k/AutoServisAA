namespace AutoServis.Model.Responses;

public class PartResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Sku { get; set; }
    public decimal UnitPrice { get; set; }
    public bool IsActive { get; set; }
}
