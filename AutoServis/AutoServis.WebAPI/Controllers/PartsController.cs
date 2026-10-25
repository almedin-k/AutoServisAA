using AutoServis.Model.Constants;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Catalog;
using Microsoft.AspNetCore.Authorization;

namespace AutoServis.WebAPI.Controllers;

[Authorize(Roles = Roles.Staff)]
public class PartsController
    : BaseCRUDController<PartResponse, PartSearchObject, PartUpsertRequest, PartUpsertRequest, IPartService>
{
    public PartsController(IPartService service) : base(service)
    {
    }
}
