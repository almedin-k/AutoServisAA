using AutoServis.Model.Constants;
using AutoServis.Model.SearchObjects;
using AutoServis.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

// CRUD endpoints. Write operations are restricted to staff (Admin and Manager).
public abstract class BaseCRUDController<TResponse, TSearch, TInsertRequest, TUpdateRequest, TService>
    : BaseReadController<TResponse, TSearch, TService>
    where TSearch : BaseSearchObject, new()
    where TService : IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
{
    protected BaseCRUDController(TService service) : base(service)
    {
    }

    [HttpPost]
    [Authorize(Roles = Roles.Staff)]
    public virtual async Task<ActionResult<TResponse>> Create(
        [FromBody] TInsertRequest request, CancellationToken cancellationToken)
    {
        var result = await Service.InsertAsync(request, cancellationToken);
        return StatusCode(StatusCodes.Status201Created, result);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.Staff)]
    public virtual async Task<ActionResult<TResponse>> Update(
        int id, [FromBody] TUpdateRequest request, CancellationToken cancellationToken)
    {
        return Ok(await Service.UpdateAsync(id, request, cancellationToken));
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Staff)]
    public virtual async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await Service.DeleteAsync(id, cancellationToken);
        return NoContent();
    }
}
