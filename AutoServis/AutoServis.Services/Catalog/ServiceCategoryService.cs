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

public class ServiceCategoryService
    : BaseCRUDService<ServiceCategory, ServiceCategoryResponse, ServiceCategorySearchObject, ServiceCategoryUpsertRequest, ServiceCategoryUpsertRequest>,
      IServiceCategoryService
{
    private readonly IAuthenticatedUserAccessor _currentUser;

    public ServiceCategoryService(
        AutoServisDbContext dbContext,
        IMapper mapper,
        IValidator<ServiceCategoryUpsertRequest> validator,
        IAuthenticatedUserAccessor currentUser)
        : base(dbContext, mapper, validator, validator)
    {
        _currentUser = currentUser;
    }

    protected override string EntityName => "Service category";

    protected override string InUseMessage =>
        "This category contains services and cannot be deleted. Deactivate it instead.";

    protected override IQueryable<ServiceCategory> ApplyFilters(IQueryable<ServiceCategory> query, ServiceCategorySearchObject search)
    {
        if (_currentUser.IsStaff())
        {
            if (search.IsActive.HasValue)
            {
                query = query.Where(c => c.IsActive == search.IsActive.Value);
            }
        }
        else
        {
            query = query.Where(c => c.IsActive);
        }

        if (!string.IsNullOrWhiteSpace(search.Name))
        {
            query = query.Where(c => c.Name.Contains(search.Name));
        }

        return query;
    }

    protected override IQueryable<ServiceCategory> ApplySorting(IQueryable<ServiceCategory> query, ServiceCategorySearchObject search)
        => query.OrderBy(c => c.Name);

    public override async Task<ServiceCategoryResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var response = await base.GetByIdAsync(id, cancellationToken);

        if (!response.IsActive && !_currentUser.IsStaff())
        {
            throw new NotFoundException(EntityName, id);
        }

        return response;
    }

    protected override async Task ValidateInsertAsync(ServiceCategoryUpsertRequest request, CancellationToken cancellationToken)
    {
        if (await DbContext.ServiceCategories.AnyAsync(c => c.Name == request.Name, cancellationToken))
        {
            throw new BusinessException($"A category named '{request.Name}' already exists.");
        }
    }

    protected override async Task ValidateUpdateAsync(int id, ServiceCategoryUpsertRequest request, CancellationToken cancellationToken)
    {
        if (await DbContext.ServiceCategories.AnyAsync(c => c.Name == request.Name && c.Id != id, cancellationToken))
        {
            throw new BusinessException($"A category named '{request.Name}' already exists.");
        }
    }
}
