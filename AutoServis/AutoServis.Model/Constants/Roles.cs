namespace AutoServis.Model.Constants;
public static class Roles
{
    public const string Admin = "Admin";
    public const string Manager = "Manager";
    public const string Mechanic = "Mechanic";
    public const string Client = "Client";

    //Comma separated list used in [Authorize(Roles = ...)] for staff-only endpoints.
    public const string Staff = Admin + "," + Manager;
}
