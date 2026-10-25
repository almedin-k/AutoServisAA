namespace AutoServis.Services;

/// Gives services access to the identity of the current request. The user id always comes from the validated access token, never from the route or the request body.
public interface IAuthenticatedUserAccessor
{
    int? GetUserId();
    int? GetSessionId();
    bool IsInRole(string role);
}
