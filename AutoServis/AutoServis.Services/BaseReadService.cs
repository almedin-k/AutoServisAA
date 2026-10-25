using AutoServis.Model.Exceptions;
using AutoServis.Model.Responses;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services;

// Generic read service. Filtering, sorting and paging are always executed in the database.
public abstract class BaseReadService<TEntity, TResponse, TSearch> : IBaseReadService<TResponse, TSearch>
    where TEntity : class
    where TSearch : BaseSearchObject, new()
{
    protected BaseReadService(AutoServisDbContext dbContext, IMapper mapper)
    {
        DbContext = dbContext;
        Mapper = mapper;
    }

    protected AutoServisDbContext DbContext { get; }
    protected IMapper Mapper { get; }

    //Human readable entity name used in error messages.
    protected abstract string EntityName { get; }

    protected abstract IQueryable<TEntity> ApplyFilters(IQueryable<TEntity> query, TSearch search);

    protected abstract IQueryable<TEntity> ApplySorting(IQueryable<TEntity> query, TSearch search);

    protected virtual IQueryable<TEntity> ApplyIncludes(IQueryable<TEntity> query) => query;

    public virtual async Task<PageResult<TResponse>> GetAllAsync(TSearch? search, CancellationToken cancellationToken = default)
    {
        search ??= new TSearch();

        var filtered = ApplyFilters(DbContext.Set<TEntity>().AsNoTracking(), search);
        var totalCount = await filtered.CountAsync(cancellationToken);

        var items = await ApplyIncludes(ApplySorting(filtered, search))
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .ToListAsync(cancellationToken);

        return new PageResult<TResponse>
        {
            Items = Mapper.Map<List<TResponse>>(items),
            TotalCount = totalCount,
            Page = search.Page,
            PageSize = search.PageSize
        };
    }

    public virtual async Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await ApplyIncludes(DbContext.Set<TEntity>().AsNoTracking())
            .FirstOrDefaultAsync(e => EF.Property<int>(e, "Id") == id, cancellationToken);

        if (entity is null)
        {
            throw new NotFoundException(EntityName, id);
        }

        return Mapper.Map<TResponse>(entity);
    }
}
