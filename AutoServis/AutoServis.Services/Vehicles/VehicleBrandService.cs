using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using AutoServis.Services.Database.Entities;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services.Vehicles;
public class VehicleBrandService
    : BaseCRUDService<VehicleBrand, VehicleBrandResponse, VehicleBrandSearchObject, VehicleBrandUpsertRequest, VehicleBrandUpsertRequest>,
      IVehicleBrandService
{
    public VehicleBrandService(
        AutoServisDbContext dbContext,
        IMapper mapper,
        IValidator<VehicleBrandUpsertRequest> validator)
        : base(dbContext, mapper, validator, validator)
    {
    }

    protected override string EntityName => "VehicleBrand";
    protected override string InUseMessage => "Postoje aktivna vozila sa ovim brendom i ne može se obrisati.";
    protected override IQueryable<VehicleBrand> ApplyFilters(IQueryable<VehicleBrand> query, VehicleBrandSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(b => b.Name.Contains(search.Name));
        }
        return query;
    }
    protected override IQueryable<VehicleBrand> ApplySorting(IQueryable<VehicleBrand> query, VehicleBrandSearchObject search)
        => query.OrderBy(b => b.Name);
    protected override async Task ValidateInsertAsync(VehicleBrandUpsertRequest request, CancellationToken cancellationToken)
    {
        if (await DbContext.VehicleBrands.AnyAsync(b => b.Name == request.Name, cancellationToken))
        {
            throw new BusinessException($"Brend '{request.Name}' već postoji.");
        }
    }
    protected override async Task ValidateUpdateAsync(int id, VehicleBrandUpsertRequest request, CancellationToken cancellationToken)
    {
        if (await DbContext.VehicleBrands.AnyAsync(b => b.Name == request.Name && b.Id != id, cancellationToken))
        {
            throw new BusinessException($"Brend '{request.Name}' već postoji.");
        }
    }
}