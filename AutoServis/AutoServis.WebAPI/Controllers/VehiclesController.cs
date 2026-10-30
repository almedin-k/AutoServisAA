using AutoServis.Model.Constants;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Vehicles;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

public class VehiclesController : BaseReadController<VehicleResponse, VehicleSearchObject, IVehicleService>
{
    private const string WriteRoles = Roles.Staff + "," + Roles.Client;
    public VehiclesController(IVehicleService service) : base(service)
    {
    }

    [HttpPost]
    [Authorize(Roles = WriteRoles)]
    public async Task<ActionResult<VehicleResponse>> Create(
        [FromBody] VehicleUpsertRequest request, CancellationToken cancellationToken)
    {
        var result = await Service.InsertAsync(request, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, result);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = WriteRoles)]
    public async Task<ActionResult<VehicleResponse>> Update(
        int id, [FromBody] VehicleUpsertRequest request, CancellationToken cancellationToken)
    {
        return Ok(await Service.UpdateAsync(id, request, cancellationToken));
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = WriteRoles)]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await Service.DeleteAsync(id, cancellationToken);
        return NoContent();
    }
}