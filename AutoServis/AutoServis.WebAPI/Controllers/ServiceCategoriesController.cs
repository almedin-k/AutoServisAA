using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Catalog;

namespace AutoServis.WebAPI.Controllers;

public class ServiceCategoriesController
    : BaseCRUDController<ServiceCategoryResponse, ServiceCategorySearchObject, ServiceCategoryUpsertRequest, ServiceCategoryUpsertRequest, IServiceCategoryService>
{
    public ServiceCategoriesController(IServiceCategoryService service) : base(service)
    {
    }
}
