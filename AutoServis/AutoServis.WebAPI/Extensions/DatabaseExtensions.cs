using AutoServis.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace AutoServis.WebAPI.Extensions;

public static class DatabaseExtensions
{
    private const int MaxAttempts = 10;
    private static readonly TimeSpan RetryDelay = TimeSpan.FromSeconds(3);

    /// <summary>
    /// Applies pending migrations (and the seed data they contain). SQL Server in a container can need
    /// a few seconds to accept connections, so the call is retried before giving up.
    /// </summary>
    public static async Task MigrateDatabaseAsync(this WebApplication app)
    {
        var logger = app.Services.GetRequiredService<ILoggerFactory>().CreateLogger("DatabaseMigration");

        for (var attempt = 1; ; attempt++)
        {
            try
            {
                await using var scope = app.Services.CreateAsyncScope();
                var dbContext = scope.ServiceProvider.GetRequiredService<AutoServisDbContext>();
                await dbContext.Database.MigrateAsync();

                logger.LogInformation("Database is up to date.");
                return;
            }
            catch (Exception ex) when (attempt < MaxAttempts)
            {
                logger.LogWarning(ex, "Database is not ready (attempt {Attempt}/{MaxAttempts}). Retrying...", attempt, MaxAttempts);
                await Task.Delay(RetryDelay);
            }
        }
    }
}
