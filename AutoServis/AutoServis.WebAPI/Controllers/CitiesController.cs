using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Cities;

namespace AutoServis.WebAPI.Controllers;

public class CitiesController
    : BaseCRUDController<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest, ICityService>
{
    public CitiesController(ICityService service) : base(service)
    {
    }
}
