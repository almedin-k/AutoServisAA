namespace AutoServis.Model.SearchObjects;

public class CitySearchObject : BaseSearchObject
{
    /// <summary>Substring of the city name (case-insensitive).</summary>
    public string? Name { get; set; }
}
