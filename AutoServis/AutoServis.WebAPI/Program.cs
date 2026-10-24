using System.Text.Json.Serialization;
using AutoServis.Services;
using AutoServis.Services.Configuration;
using AutoServis.Services.Database;
using AutoServis.WebAPI;
using AutoServis.WebAPI.Extensions;
using AutoServis.WebAPI.Filters;
using AutoServis.WebAPI.Services;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Serilog;
using Serilog.Events;

// Load the .env file for local development. Real environment variables (for example the ones
// set by docker compose) always take precedence.
DotEnvLoader.Load();

const string CorsPolicyName = "AllowedOrigins";

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, services, configuration) => configuration
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.EntityFrameworkCore.Database.Command", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.File("logs/autoservis-.log", rollingInterval: RollingInterval.Day, retainedFileCountLimit: 14));

var settings = AppSettings.FromConfiguration(builder.Configuration);

// Outside Docker the port comes from .env. In Docker, ASPNETCORE_URLS is set by docker-compose.yml.
if (string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("ASPNETCORE_URLS")))
{
    builder.WebHost.UseUrls($"http://localhost:{settings.ApiPort}");
}

builder.Services.AddSingleton(settings);
builder.Services.AddSingleton(new SessionSettings(settings.Jwt.RefreshTokenDays));

builder.Services.AddDbContext<AutoServisDbContext>(options =>
    options.UseSqlServer(settings.Database.ConnectionString));

builder.Services.AddMapster();
builder.Services.AddServiceLayer();

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IAuthenticatedUserAccessor, HttpAuthenticatedUserAccessor>();
builder.Services.AddScoped<IAccessManager, AccessManager>();

builder.Services
    .AddControllers(options => options.Filters.Add<ExceptionFilter>())
    .AddJsonOptions(options => options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

builder.Services.AddJwtAuthentication(settings.Jwt);

builder.Services.AddCors(options => options.AddPolicy(CorsPolicyName, policy => policy
    .WithOrigins(settings.CorsAllowedOrigins)
    .AllowAnyHeader()
    .AllowAnyMethod()));

builder.Services.AddSwaggerWithJwt();

var app = builder.Build();

await app.MigrateDatabaseAsync();

app.UseSerilogRequestLogging();
app.UseSwagger();
app.UseSwaggerUI();
app.UseCors(CorsPolicyName);
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
