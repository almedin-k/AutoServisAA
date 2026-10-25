using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services.Catalog;

public interface IServiceCategoryService
    : IBaseCRUDService<ServiceCategoryResponse, ServiceCategorySearchObject, ServiceCategoryUpsertRequest, ServiceCategoryUpsertRequest>
{
}
