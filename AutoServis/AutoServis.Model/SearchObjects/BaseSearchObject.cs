using AutoServis.Model.Constants;

namespace AutoServis.Model.SearchObjects;

/// <summary>
/// Common paging parameters for every list endpoint. The page size is always capped.
/// </summary>
public class BaseSearchObject
{
    private int _page = 1;
    private int _pageSize = PagingDefaults.DefaultPageSize;

    public int Page
    {
        get => _page;
        set => _page = value < 1 ? 1 : value;
    }

    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = Math.Clamp(value, 1, PagingDefaults.MaxPageSize);
    }
}
