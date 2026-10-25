using AutoServis.Common.Services;
using AutoServis.Services.Auth;
using AutoServis.Services.Catalog;
using AutoServis.Services.Cities;
using AutoServis.Services.Mapping;
using FluentValidation;
using Mapster;
using Microsoft.Extensions.DependencyInjection;

namespace AutoServis.Services;

public static class ServiceCollectionExtensions
{
    //Registers the service layer. Services that use the DbContext are Scoped.
    public static IServiceCollection AddServiceLayer(this IServiceCollection services)
    {
        services.AddMemoryCache();

        // Registers every IRegister (custom Mapster mappings) found in this assembly.
        TypeAdapterConfig.GlobalSettings.Scan(typeof(MappingConfig).Assembly);

        services.AddSingleton<IPasswordHasher, PasswordHasher>();
        services.AddSingleton<ISecureTokenGenerator, SecureTokenGenerator>();

        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ICityService, CityService>();
        services.AddScoped<IServiceCategoryService, ServiceCategoryService>();
        services.AddScoped<IServiceService, ServiceService>();
        services.AddScoped<IPartService, PartService>();

        AddValidators(services);

        return services;
    }

    private static void AddValidators(IServiceCollection services)
    {
        var validatorTypes = typeof(ServiceCollectionExtensions).Assembly
            .GetTypes()
            .Where(t => t is { IsAbstract: false, IsInterface: false });

        foreach (var validatorType in validatorTypes)
        {
            var serviceTypes = validatorType.GetInterfaces()
                .Where(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IValidator<>));

            foreach (var serviceType in serviceTypes)
            {
                services.AddScoped(serviceType, validatorType);
            }
        }
    }
}
