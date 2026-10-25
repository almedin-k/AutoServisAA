using AutoServis.Model.Constants;
using AutoServis.Model.Enums;
using AutoServis.Model.Exceptions;
using AutoServis.Model.Requests;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using AutoServis.Services.Database.Entities;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services.Catalog;

public class ServiceService
    : BaseCRUDService<Service, ServiceResponse, ServiceSearchObject, ServiceUpsertRequest, ServiceUpsertRequest>,
      IServiceService
{
    //Opening the same service again within this window is not counted as a new view.
    private static readonly TimeSpan ViewThrottle = TimeSpan.FromMinutes(10);

    private readonly IAuthenticatedUserAccessor _currentUser;

    public ServiceService(
        AutoServisDbContext dbContext,
        IMapper mapper,
        IValidator<ServiceUpsertRequest> validator,
        IAuthenticatedUserAccessor currentUser)
        : base(dbContext, mapper, validator, validator)
    {
        _currentUser = currentUser;
    }

    protected override string EntityName => "Service";

    protected override string InUseMessage =>
        "This service is used by appointments and cannot be deleted. Deactivate it instead.";


    protected override IQueryable<Service> ApplyFilters(IQueryable<Service> query, ServiceSearchObject search)
    {
        if (_currentUser.IsStaff())
        {
            if (search.IsActive.HasValue)
            {
                query = query.Where(s => s.IsActive == search.IsActive.Value);
            }
        }
        else
        {
            query = query.Where(s => s.IsActive && s.Category.IsActive);
        }

        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(s => s.Name.Contains(search.Name));
        }

        if (search.CategoryId.HasValue)
        {
            query = query.Where(s => s.CategoryId == search.CategoryId.Value);
        }

        if (search.MinPrice.HasValue)
        {
            query = query.Where(s => s.Price >= search.MinPrice.Value);
        }

        if (search.MaxPrice.HasValue)
        {
            query = query.Where(s => s.Price <= search.MaxPrice.Value);
        }

        return query;
    }

    protected override IQueryable<Service> ApplySorting(IQueryable<Service> query, ServiceSearchObject search)
    {
        return search.SortBy switch
        {
            ServiceSortOption.PriceAscending => query.OrderBy(s => s.Price).ThenBy(s => s.Name),
            ServiceSortOption.PriceDescending => query.OrderByDescending(s => s.Price).ThenBy(s => s.Name),
            ServiceSortOption.ShortestFirst => query.OrderBy(s => s.DurationMinutes).ThenBy(s => s.Name),
            ServiceSortOption.Newest => query.OrderByDescending(s => s.CreatedAt).ThenBy(s => s.Name),
            _ => query.OrderBy(s => s.Name).ThenBy(s => s.Id)
        };
    }

    protected override IQueryable<Service> ApplyIncludes(IQueryable<Service> query)
        => query.Include(s => s.Category);

    public override async Task<ServiceResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var response = await LoadDetailsAsync(id, cancellationToken);
        await RecordViewAsync(id, cancellationToken);
        return response;
    }

    private async Task<ServiceResponse> LoadDetailsAsync(int id, CancellationToken cancellationToken)
    {
        var service = await DbContext.Services
            .AsNoTracking()
            .Include(s => s.Category)
            .Include(s => s.ServiceParts).ThenInclude(sp => sp.Part)
            .FirstOrDefaultAsync(s => s.Id == id, cancellationToken);

        if (service is null || (!_currentUser.IsStaff() && !(service.IsActive && service.Category.IsActive)))
        {
            throw new NotFoundException(EntityName, id);
        }

        var response = Mapper.Map<ServiceResponse>(service);
        response.RequiredParts = response.RequiredParts.OrderBy(p => p.PartName).ToList();
        return response;
    }

    private async Task RecordViewAsync(int serviceId, CancellationToken cancellationToken)
    {
        if (!_currentUser.IsInRole(Roles.Client))
        {
            return;
        }

        var userId = _currentUser.GetUserId();
        if (userId is null)
        {
            return;
        }

        var since = DateTime.UtcNow - ViewThrottle;
        var viewedRecently = await DbContext.ServiceViews.AnyAsync(
            v => v.UserId == userId.Value && v.ServiceId == serviceId && v.ViewedAt >= since,
            cancellationToken);

        if (viewedRecently)
        {
            return;
        }

        DbContext.ServiceViews.Add(new ServiceView
        {
            UserId = userId.Value,
            ServiceId = serviceId,
            ViewedAt = DateTime.UtcNow
        });
        await DbContext.SaveChangesAsync(cancellationToken);
    }


    protected override Task ValidateInsertAsync(ServiceUpsertRequest request, CancellationToken cancellationToken)
        => ValidateRulesAsync(null, request, cancellationToken);

    protected override Task ValidateUpdateAsync(int id, ServiceUpsertRequest request, CancellationToken cancellationToken)
        => ValidateRulesAsync(id, request, cancellationToken);

    private async Task ValidateRulesAsync(int? id, ServiceUpsertRequest request, CancellationToken cancellationToken)
    {
        var category = await DbContext.ServiceCategories
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == request.CategoryId, cancellationToken);

        if (category is null)
        {
            throw new BusinessException("The selected category does not exist.");
        }

        if (!category.IsActive && request.IsActive)
        {
            throw new BusinessException("An active service cannot belong to an inactive category.");
        }

        var duplicate = await DbContext.Services.AnyAsync(
            s => s.CategoryId == request.CategoryId
                 && s.Name == request.Name
                 && (!id.HasValue || s.Id != id.Value),
            cancellationToken);

        if (duplicate)
        {
            throw new BusinessException($"A service named '{request.Name}' already exists in this category.");
        }

        var partIds = request.RequiredParts.Select(p => p.PartId).Distinct().ToList();
        if (partIds.Count > 0)
        {
            var existingParts = await DbContext.Parts.CountAsync(p => partIds.Contains(p.Id), cancellationToken);
            if (existingParts != partIds.Count)
            {
                throw new BusinessException("One or more selected parts do not exist.");
            }
        }
    }

    protected override void OnInserting(Service entity)
    {
        entity.CreatedAt = DateTime.UtcNow;
        entity.HasImage = false;
    }

    protected override void OnUpdating(Service entity)
    {
        entity.UpdatedAt = DateTime.UtcNow;
    }

    protected override Task BeforeInsertSaveAsync(Service entity, ServiceUpsertRequest request, CancellationToken cancellationToken)
    {
        entity.ServiceParts = request.RequiredParts
            .Select(p => new ServicePart { PartId = p.PartId, Quantity = p.Quantity })
            .ToList();

        return Task.CompletedTask;
    }

    protected override async Task BeforeUpdateSaveAsync(Service entity, ServiceUpsertRequest request, CancellationToken cancellationToken)
    {
        var current = await DbContext.ServiceParts
            .Where(sp => sp.ServiceId == entity.Id)
            .ToListAsync(cancellationToken);

        var requested = request.RequiredParts.ToDictionary(p => p.PartId);

        foreach (var existing in current)
        {
            if (requested.TryGetValue(existing.PartId, out var wanted))
            {
                existing.Quantity = wanted.Quantity;
            }
            else
            {
                DbContext.ServiceParts.Remove(existing);
            }
        }

        var currentPartIds = current.Select(c => c.PartId).ToHashSet();
        foreach (var wanted in requested.Values.Where(r => !currentPartIds.Contains(r.PartId)))
        {
            DbContext.ServiceParts.Add(new ServicePart
            {
                ServiceId = entity.Id,
                PartId = wanted.PartId,
                Quantity = wanted.Quantity
            });
        }
    }

    protected override Task<ServiceResponse> ToResponseAsync(Service entity, CancellationToken cancellationToken)
        => LoadDetailsAsync(entity.Id, cancellationToken);


    public async Task<ServiceImageResponse> GetImageAsync(int serviceId, CancellationToken cancellationToken = default)
    {
        var image = await DbContext.ServiceImages
            .AsNoTracking()
            .Where(i => i.ServiceId == serviceId)
            .Select(i => new ServiceImageResponse { Data = i.Data, ContentType = i.ContentType })
            .FirstOrDefaultAsync(cancellationToken);

        return image ?? throw new NotFoundException("This service has no image.");
    }

    public async Task SetImageAsync(int serviceId, byte[] data, CancellationToken cancellationToken = default)
    {
        if (data.Length == 0)
        {
            throw new BusinessException("The image file is empty.");
        }

        if (data.Length > ServiceImageRules.MaxBytes)
        {
            throw new BusinessException(
                $"The image is too large. The maximum size is {ServiceImageRules.MaxBytes / (1024 * 1024)} MB.");
        }

        var contentType = ImageSignature.Detect(data)
            ?? throw new BusinessException($"Only {ServiceImageRules.AllowedFormatsDescription} images are allowed.");

        var service = await DbContext.Services
            .Include(s => s.Image)
            .FirstOrDefaultAsync(s => s.Id == serviceId, cancellationToken)
            ?? throw new NotFoundException(EntityName, serviceId);

        if (service.Image is null)
        {
            service.Image = new ServiceImage { Data = data, ContentType = contentType };
        }
        else
        {
            service.Image.Data = data;
            service.Image.ContentType = contentType;
        }

        service.HasImage = true;
        service.UpdatedAt = DateTime.UtcNow;

        await DbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteImageAsync(int serviceId, CancellationToken cancellationToken = default)
    {
        var service = await DbContext.Services
            .Include(s => s.Image)
            .FirstOrDefaultAsync(s => s.Id == serviceId, cancellationToken)
            ?? throw new NotFoundException(EntityName, serviceId);

        if (service.Image is null)
        {
            return;
        }

        DbContext.ServiceImages.Remove(service.Image);
        service.HasImage = false;
        service.UpdatedAt = DateTime.UtcNow;

        await DbContext.SaveChangesAsync(cancellationToken);
    }
}
