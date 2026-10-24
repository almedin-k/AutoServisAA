namespace AutoServis.Model.Requests;

public class CityUpsertRequest
{
    public string Name { get; set; } = string.Empty;
    public string? PostalCode { get; set; }
}
