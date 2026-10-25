using AutoServis.Model.Constants;

namespace AutoServis.Services;

public static class AuthenticatedUserAccessorExtensions
{
    //True for Admin and Manager. Staff can see inactive catalog records, clients cannot
    public static bool IsStaff(this IAuthenticatedUserAccessor accessor)
        => accessor.IsInRole(Roles.Admin) || accessor.IsInRole(Roles.Manager);
}
