using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using AutoServis.Services.Database.Entities;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services.Cities;

public class CityService
    : BaseCRUDService<City, CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>, ICityService
{
    public CityService(AutoServisDbContext dbContext, IMapper mapper, IValidator<CityUpsertRequest> validator)
        : base(dbContext, mapper, validator, validator)
    {
    }

    protected override string EntityName => "City";

    protected override string InUseMessage => "This city is assigned to users and cannot be deleted.";

    protected override IQueryable<City> ApplyFilters(IQueryable<City> query, CitySearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(c => c.Name.Contains(search.Name));
        }

        return query;
    }

    protected override IQueryable<City> ApplySorting(IQueryable<City> query, CitySearchObject search)
        => query.OrderBy(c => c.Name);

    protected override async Task ValidateInsertAsync(CityUpsertRequest request, CancellationToken cancellationToken)
    {
        if (await DbContext.Cities.AnyAsync(c => c.Name == request.Name, cancellationToken))
        {
            throw new BusinessException($"A city named '{request.Name}' already exists.");
        }
    }

    protected override async Task ValidateUpdateAsync(int id, CityUpsertRequest request, CancellationToken cancellationToken)
    {
        if (await DbContext.Cities.AnyAsync(c => c.Name == request.Name && c.Id != id, cancellationToken))
        {
            throw new BusinessException($"A city named '{request.Name}' already exists.");
        }
    }
}
