using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoServis.WebAPI.Controllers;

/// <summary>
/// Read-only endpoints (list with filters and paging, get by id). Authentication is required.
/// </summary>
[ApiController]
[Route("[controller]")]
[Authorize]
public abstract class BaseReadController<TResponse, TSearch, TService> : ControllerBase
    where TSearch : BaseSearchObject, new()
    where TService : IBaseReadService<TResponse, TSearch>
{
    protected BaseReadController(TService service)
    {
        Service = service;
    }

    protected TService Service { get; }

    [HttpGet]
    public virtual async Task<ActionResult<PageResult<TResponse>>> GetAll(
        [FromQuery] TSearch search, CancellationToken cancellationToken)
    {
        return Ok(await Service.GetAllAsync(search, cancellationToken));
    }

    [HttpGet("{id:int}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id, CancellationToken cancellationToken)
    {
        return Ok(await Service.GetByIdAsync(id, cancellationToken));
    }
}
