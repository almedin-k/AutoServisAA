using AutoServis.Model.SearchObjects;

namespace AutoServis.Services;

public interface IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
    : IBaseReadService<TResponse, TSearch>
    where TSearch : BaseSearchObject
{
    Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default);
    Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}
