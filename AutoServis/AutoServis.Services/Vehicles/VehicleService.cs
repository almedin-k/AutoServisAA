using AutoServis.Model.Constants;
using AutoServis.Model.Enums;
using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using AutoServis.Services.Database.Entities;
using FluentValidation;
using FluentValidation.Results;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services.Vehicles;

// Vehicles of the clients. A client can only see and change their own vehicles, staff can edit all of them.
// A vehicle is never physically deleted, so the service history stays linked to it.
public class VehicleService
    : BaseCRUDService<Vehicle, VehicleResponse, VehicleSearchObject, VehicleUpsertRequest, VehicleUpsertRequest>,
      IVehicleService
{
    private static readonly AppointmentStatusType[] ActiveStatuses =
    {
        AppointmentStatusType.Pending,
        AppointmentStatusType.Approved,
        AppointmentStatusType.Confirmed
    };

    private readonly IAuthenticatedUserAccessor _currentUser;
    public VehicleService(
        AutoServisDbContext dbContext,
        IMapper mapper,
        IValidator<VehicleUpsertRequest> validator,
        IAuthenticatedUserAccessor currentUser)
        : base(dbContext, mapper, validator, validator)
    {
        _currentUser = currentUser;
    }
    protected override string EntityName => "Vehicle";
    private bool CanSeeAllVehicles => _currentUser.IsStaff() || _currentUser.IsInRole(Roles.Mechanic);
    protected override IQueryable<Vehicle> ApplyFilters(IQueryable<Vehicle> query, VehicleSearchObject search)
    {
        query = query.Where(v => !v.IsDeleted);
        if (CanSeeAllVehicles)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(v => v.UserId == search.UserId.Value);
            }
        }
        else
        {
            var ownerId = _currentUser.GetUserId() ?? -1;
            query = query.Where(v => v.UserId == ownerId);
        }
        if (search.BrandId.HasValue)
        {
            query = query.Where(v => v.BrandId == search.BrandId.Value);
        }
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            var text = search.Text.Trim();
            query = query.Where(v => v.Model.Contains(text) || v.Brand.Name.Contains(text) || v.Vin.Contains(text));
        }
        return query;
    }
    protected override IQueryable<Vehicle> ApplySorting(IQueryable<Vehicle> query, VehicleSearchObject search)
        => query.OrderBy(v => v.Brand.Name).ThenBy(v => v.Model).ThenBy(v => v.Id);

    private static IQueryable<VehicleResponse> Project(IQueryable<Vehicle> query)
    {
        return query.Select(v => new VehicleResponse
        {
            Id = v.Id,
            UserId = v.UserId,
            OwnerName = v.User.FirstName + " " + v.User.LastName,
            BrandId = v.BrandId,
            BrandName = v.Brand.Name,
            Model = v.Model,
            ProductionYear = v.ProductionYear,
            EngineType = v.EngineType,
            EngineDisplacementCc = v.EngineDisplacementCc,
            EnginePowerKw = v.EnginePowerKw,
            Vin = v.Vin,
            MileageKm = v.MileageKm,
            CreatedAt = v.CreatedAt
        });
    }

    public override async Task<PageResult<VehicleResponse>> GetAllAsync(
        VehicleSearchObject? search, CancellationToken cancellationToken = default)
    {
        search ??= new VehicleSearchObject();
        var filtered = ApplyFilters(DbContext.Vehicles.AsNoTracking(), search);
        var totalCount = await filtered.CountAsync(cancellationToken);
        var page = ApplySorting(filtered, search)
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize);
        var items = await Project(page).ToListAsync(cancellationToken);
        return new PageResult<VehicleResponse>
        {
            Items = items,
            TotalCount = totalCount,
            Page = search.Page,
            PageSize = search.PageSize
        };
    }

    public override async Task<VehicleResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var visible = ApplyFilters(DbContext.Vehicles.AsNoTracking(), new VehicleSearchObject());
        var response = await Project(visible.Where(v => v.Id == id)).FirstOrDefaultAsync(cancellationToken);
        return response ?? throw new NotFoundException(EntityName, id);
    }

    protected override async Task ValidateInsertAsync(VehicleUpsertRequest request, CancellationToken cancellationToken)
    {
        await ValidateRulesAsync(null, request, cancellationToken);
        if (_currentUser.IsStaff())
        {
            await ValidateOwnerAsync(request.UserId, cancellationToken);
        }
    }

    protected override async Task ValidateUpdateAsync(int id, VehicleUpsertRequest request, CancellationToken cancellationToken)
    {
        var isVisible = await ApplyFilters(DbContext.Vehicles.AsNoTracking(), new VehicleSearchObject())
            .AnyAsync(v => v.Id == id, cancellationToken);
        if (!isVisible)
        {
            throw new NotFoundException(EntityName, id);
        }
        await ValidateRulesAsync(id, request, cancellationToken);
    }

    private async Task ValidateRulesAsync(int? vehicleId, VehicleUpsertRequest request, CancellationToken cancellationToken)
    {
        if (!await DbContext.VehicleBrands.AnyAsync(b => b.Id == request.BrandId, cancellationToken))
        {
            throw FieldError(nameof(request.BrandId), "Odabrani brend vozila ne postoji.");
        }
        var vin = NormalizeVin(request.Vin);
        var duplicate = await DbContext.Vehicles.AnyAsync(
            v => !v.IsDeleted && v.Vin == vin && (!vehicleId.HasValue || v.Id != vehicleId.Value),
            cancellationToken);

        if (duplicate)
        {
            throw FieldError(nameof(request.Vin), "Vozilo s ovim brojem šasije je već evidentirano.");
        }
    }
    private async Task ValidateOwnerAsync(int? ownerId, CancellationToken cancellationToken)
    {
        if (!ownerId.HasValue)
        {
            throw FieldError(nameof(VehicleUpsertRequest.UserId), "Odaberite vlasnika vozila.");
        }
        var isClient = await DbContext.Users.AnyAsync(
            u => u.Id == ownerId.Value && u.IsActive && u.UserRoles.Any(ur => ur.Role.Name == Roles.Client),
            cancellationToken);

        if (!isClient)
        {
            throw FieldError(nameof(VehicleUpsertRequest.UserId), "Vlasnik vozila mora biti aktivan klijent.");
        }
    }

    protected override void OnInserting(Vehicle entity)
    {
        entity.Vin = NormalizeVin(entity.Vin);
        entity.IsDeleted = false;
        entity.CreatedAt = DateTime.UtcNow;
    }

    protected override void OnUpdating(Vehicle entity)
    {
        entity.Vin = NormalizeVin(entity.Vin);
    }

    protected override Task BeforeInsertSaveAsync(Vehicle entity, VehicleUpsertRequest request, CancellationToken cancellationToken)
    {
        if (_currentUser.IsStaff())
        {
            entity.UserId = request.UserId!.Value;
        }
        else
        {
            entity.UserId = _currentUser.GetUserId()
                ?? throw new AuthenticationFailedException("Vaša sesija je istekla. Prijavite se ponovo.");
        }
        return Task.CompletedTask;
    }

    protected override Task<VehicleResponse> ToResponseAsync(Vehicle entity, CancellationToken cancellationToken)
        => GetByIdAsync(entity.Id, cancellationToken);

    public override async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var vehicle = await ApplyFilters(DbContext.Vehicles, new VehicleSearchObject())
            .FirstOrDefaultAsync(v => v.Id == id, cancellationToken)
            ?? throw new NotFoundException(EntityName, id);

        var hasActiveAppointment = await DbContext.Appointments.AnyAsync(
            a => a.VehicleId == id && ActiveStatuses.Contains(a.StatusId),
            cancellationToken);
        if (hasActiveAppointment)
        {
            throw new BusinessException("Vozilo ima aktivnu rezervaciju i ne može se obrisati. Prvo otkažite rezervaciju.");
        }
        vehicle.IsDeleted = true;
        await DbContext.SaveChangesAsync(cancellationToken);
    }

    //A VIN is stored in upper case without spaces, so the unique check is reliable
    private static string NormalizeVin(string vin) => vin.Trim().ToUpperInvariant();
    private static ValidationException FieldError(string propertyName, string message)
        => new(new[] { new ValidationFailure(propertyName, message) });
}