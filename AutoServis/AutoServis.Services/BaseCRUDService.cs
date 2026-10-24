using AutoServis.Model.Exceptions;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using FluentValidation;
using MapsterMapper;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services;

/// <summary>
/// Generic CRUD service. Requests are validated with FluentValidation before anything is written.
/// </summary>
public abstract class BaseCRUDService<TEntity, TResponse, TSearch, TInsertRequest, TUpdateRequest>
    : BaseReadService<TEntity, TResponse, TSearch>,
      IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
    where TEntity : class
    where TSearch : BaseSearchObject, new()
{
    private const int SqlServerForeignKeyViolation = 547;

    private readonly IValidator<TInsertRequest> _insertValidator;
    private readonly IValidator<TUpdateRequest> _updateValidator;

    protected BaseCRUDService(
        AutoServisDbContext dbContext,
        IMapper mapper,
        IValidator<TInsertRequest> insertValidator,
        IValidator<TUpdateRequest> updateValidator)
        : base(dbContext, mapper)
    {
        _insertValidator = insertValidator;
        _updateValidator = updateValidator;
    }

    /// <summary>Message shown when a record cannot be deleted because other records reference it.</summary>
    protected virtual string InUseMessage =>
        $"This {EntityName.ToLowerInvariant()} is used by other records and cannot be deleted.";

    /// <summary>Business checks that need the database (for example uniqueness).</summary>
    protected virtual Task ValidateInsertAsync(TInsertRequest request, CancellationToken cancellationToken)
        => Task.CompletedTask;

    protected virtual Task ValidateUpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken)
        => Task.CompletedTask;

    /// <summary>Hook for setting server-controlled fields (for example CreatedAt) on a new entity.</summary>
    protected virtual void OnInserting(TEntity entity)
    {
    }

    /// <summary>Hook for setting server-controlled fields (for example UpdatedAt) on a modified entity.</summary>
    protected virtual void OnUpdating(TEntity entity)
    {
    }

    public virtual async Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default)
    {
        await _insertValidator.ValidateAndThrowAsync(request, cancellationToken);
        await ValidateInsertAsync(request, cancellationToken);

        var entity = Mapper.Map<TEntity>(request);
        OnInserting(entity);

        DbContext.Set<TEntity>().Add(entity);
        await DbContext.SaveChangesAsync(cancellationToken);

        return Mapper.Map<TResponse>(entity);
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default)
    {
        await _updateValidator.ValidateAndThrowAsync(request, cancellationToken);

        var entity = await FindTrackedAsync(id, cancellationToken);
        await ValidateUpdateAsync(id, request, cancellationToken);

        Mapper.Map(request, entity);
        OnUpdating(entity);

        await DbContext.SaveChangesAsync(cancellationToken);

        return Mapper.Map<TResponse>(entity);
    }

    public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await FindTrackedAsync(id, cancellationToken);
        DbContext.Set<TEntity>().Remove(entity);

        try
        {
            await DbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException ex) when (ex.InnerException is SqlException { Number: SqlServerForeignKeyViolation })
        {
            throw new BusinessException(InUseMessage);
        }
    }

    protected async Task<TEntity> FindTrackedAsync(int id, CancellationToken cancellationToken)
    {
        var entity = await DbContext.Set<TEntity>()
            .FirstOrDefaultAsync(e => EF.Property<int>(e, "Id") == id, cancellationToken);

        return entity ?? throw new NotFoundException(EntityName, id);
    }
}
