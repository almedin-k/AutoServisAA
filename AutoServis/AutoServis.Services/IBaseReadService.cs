using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services;

public interface IBaseReadService<TResponse, TSearch>
    where TSearch : BaseSearchObject
{
    Task<PageResult<TResponse>> GetAllAsync(TSearch? search, CancellationToken cancellationToken = default);
    Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default);
}
