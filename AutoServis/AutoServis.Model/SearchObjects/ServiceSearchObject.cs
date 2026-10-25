using AutoServis.Model.Enums;

namespace AutoServis.Model.SearchObjects;

public class ServiceSearchObject : BaseSearchObject
{
    public string? Name { get; set; }

    public int? CategoryId { get; set; }

    public decimal? MinPrice { get; set; }

    public decimal? MaxPrice { get; set; }

    public bool? IsActive { get; set; }

    public ServiceSortOption SortBy { get; set; } = ServiceSortOption.Name;
}
