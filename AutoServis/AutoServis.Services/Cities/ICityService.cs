using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;

namespace AutoServis.Services.Cities;

public interface ICityService : IBaseCRUDService<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
{
}
