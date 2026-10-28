using AutoServis.Model.Exceptions;
using AutoServis.Model.SearchObjects;
using AutoServis.Services.Database;
using FluentValidation;
using MapsterMapper;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.Services;

// Generic CRUD service. Requests are validated with FluentValidation before anything is written.
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

    // Message shown when a record cannot be deleted because other records reference it.
    protected virtual string InUseMessage =>
        "Ovaj zapis se koristi u drugim zapisima i ne može se obrisati.";

    // Business checks that need the database (for example uniqueness).
    protected virtual Task ValidateInsertAsync(TInsertRequest request, CancellationToken cancellationToken)
        => Task.CompletedTask;

    protected virtual Task ValidateUpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken)
        => Task.CompletedTask;

    // Hook for setting server-controlled fields (for example CreatedAt) on a new entity.
    protected virtual void OnInserting(TEntity entity)
    {
    }

    // Hook for setting server-controlled fields (for example UpdatedAt) on a modified entity.
    protected virtual void OnUpdating(TEntity entity)
    {
    }

    // Hook for work that needs the request and must be saved together with the new entity (for example child rows).
    protected virtual Task BeforeInsertSaveAsync(TEntity entity, TInsertRequest request, CancellationToken cancellationToken)
        => Task.CompletedTask;

    // Hook for work that needs the request and must be saved together with the modified entity.
    protected virtual Task BeforeUpdateSaveAsync(TEntity entity, TUpdateRequest request, CancellationToken cancellationToken)
        => Task.CompletedTask;

    // Builds the response returned after a successful insert or update.
    protected virtual Task<TResponse> ToResponseAsync(TEntity entity, CancellationToken cancellationToken)
        => Task.FromResult(Mapper.Map<TResponse>(entity));

    public virtual async Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default)
    {
        await _insertValidator.ValidateAndThrowAsync(request, cancellationToken);
        await ValidateInsertAsync(request, cancellationToken);

        var entity = Mapper.Map<TEntity>(request);
        OnInserting(entity);
        await BeforeInsertSaveAsync(entity, request, cancellationToken);

        DbContext.Set<TEntity>().Add(entity);
        await DbContext.SaveChangesAsync(cancellationToken);

        return await ToResponseAsync(entity, cancellationToken);
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default)
    {
        await _updateValidator.ValidateAndThrowAsync(request, cancellationToken);

        var entity = await FindTrackedAsync(id, cancellationToken);
        await ValidateUpdateAsync(id, request, cancellationToken);

        Mapper.Map(request, entity);
        OnUpdating(entity);
        await BeforeUpdateSaveAsync(entity, request, cancellationToken);

        await DbContext.SaveChangesAsync(cancellationToken);

        return await ToResponseAsync(entity, cancellationToken);
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
