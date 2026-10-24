using AutoServis.Common.Services;
using AutoServis.Services.Auth;
using AutoServis.Services.Cities;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace AutoServis.Services;

public static class ServiceCollectionExtensions
{
    /// <summary>
    /// Registers the service layer. Services that use the DbContext are Scoped.
    /// </summary>
    public static IServiceCollection AddServiceLayer(this IServiceCollection services)
    {
        services.AddMemoryCache();

        services.AddSingleton<IPasswordHasher, PasswordHasher>();
        services.AddSingleton<ISecureTokenGenerator, SecureTokenGenerator>();

        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ICityService, CityService>();

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
