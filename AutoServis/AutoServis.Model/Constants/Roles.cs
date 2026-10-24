namespace AutoServis.Model.Constants;

/// <summary>
/// Role names. The values must match the role names stored in the database seed.
/// </summary>
public static class Roles
{
    public const string Admin = "Admin";
    public const string Manager = "Manager";
    public const string Mechanic = "Mechanic";
    public const string Client = "Client";

    /// <summary>Comma separated list used in [Authorize(Roles = ...)] for staff-only endpoints.</summary>
    public const string Staff = Admin + "," + Manager;
}
