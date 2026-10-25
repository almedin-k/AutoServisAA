using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services.Catalog;

public interface IServiceService : IBaseCRUDService<ServiceResponse, ServiceSearchObject, ServiceUpsertRequest, ServiceUpsertRequest>
{
    Task<ServiceImageResponse> GetImageAsync(int serviceId, CancellationToken cancellationToken = default);

    Task SetImageAsync(int serviceId, byte[] data, CancellationToken cancellationToken = default);

    Task DeleteImageAsync(int serviceId, CancellationToken cancellationToken = default);
}
