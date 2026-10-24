using System.Security.Claims;
using System.Text;
using AutoServis.Services.Auth;
using AutoServis.WebAPI.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

namespace AutoServis.WebAPI.Extensions;

public static class AuthenticationExtensions
{
    public static IServiceCollection AddJwtAuthentication(this IServiceCollection services, JwtSettings jwt)
    {
        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.MapInboundClaims = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwt.Issuer,
                    ValidateAudience = true,
                    ValidAudience = jwt.Audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwt.SecretKey)),
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero,
                    RoleClaimType = JwtClaimNames.Role,
                    NameClaimType = JwtClaimNames.UniqueName
                };

                options.Events = new JwtBearerEvents
                {
                    // Reject tokens whose server-side session was revoked (logout) or has expired.
                    OnTokenValidated = async context =>
                    {
                        var sessionClaim = context.Principal?.FindFirstValue(JwtClaimNames.SessionId);
                        var authService = context.HttpContext.RequestServices.GetRequiredService<IAuthService>();

                        if (!int.TryParse(sessionClaim, out var sessionId)
                            || !await authService.IsSessionActiveAsync(sessionId, context.HttpContext.RequestAborted))
                        {
                            context.Fail("The session is no longer active.");
                        }
                    }
                };
            });

        services.AddAuthorization();
        return services;
    }
}
