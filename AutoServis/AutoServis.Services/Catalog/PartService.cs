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

public class PartService
    : BaseCRUDService<Part, PartResponse, PartSearchObject, PartUpsertRequest, PartUpsertRequest>, IPartService
{
    public PartService(AutoServisDbContext dbContext, IMapper mapper, IValidator<PartUpsertRequest> validator)
        : base(dbContext, mapper, validator, validator)
    {
    }

    protected override string EntityName => "Part";

    protected override string InUseMessage =>
        "This part is used by services or appointments and cannot be deleted. Deactivate it instead.";

    protected override IQueryable<Part> ApplyFilters(IQueryable<Part> query, PartSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Text))
        {
            query = query.Where(p => p.Name.Contains(search.Text) || (p.Sku != null && p.Sku.Contains(search.Text)));
        }

        if (search.IsActive.HasValue)
        {
            query = query.Where(p => p.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<Part> ApplySorting(IQueryable<Part> query, PartSearchObject search)
        => query.OrderBy(p => p.Name).ThenBy(p => p.Id);

    protected override async Task ValidateInsertAsync(PartUpsertRequest request, CancellationToken cancellationToken)
    {
        await EnsureSkuIsUniqueAsync(null, request, cancellationToken);
    }

    protected override async Task ValidateUpdateAsync(int id, PartUpsertRequest request, CancellationToken cancellationToken)
    {
        await EnsureSkuIsUniqueAsync(id, request, cancellationToken);
    }

    private async Task EnsureSkuIsUniqueAsync(int? id, PartUpsertRequest request, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.Sku))
        {
            return;
        }

        var exists = await DbContext.Parts.AnyAsync(
            p => p.Sku == request.Sku && (!id.HasValue || p.Id != id.Value),
            cancellationToken);

        if (exists)
        {
            throw new BusinessException($"A part with SKU '{request.Sku}' already exists.");
        }
    }
}
