using AutoServis.Model.Constants;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Cities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

public class CitiesController
    : BaseCRUDController<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest, ICityService>
{
    public CitiesController(ICityService service) : base(service)
    {
    }
    /// All cities, without paging and without authentication for the mobile registration form
    [HttpGet("lookup")]
    [AllowAnonymous]
    public async Task<ActionResult<List<CityResponse>>> Lookup(CancellationToken cancellationToken)
    {
        var page = await Service.GetAllAsync(
            new CitySearchObject { PageSize = PagingDefaults.MaxPageSize },
            cancellationToken);
        return Ok(page.Items);
    }
}
