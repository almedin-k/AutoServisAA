using ModelRoles = AutoServis.Model.Constants.Roles;
using AutoServis.Model.Enums;
using AutoServis.Services.Database.Entities;

namespace AutoServis.Services.Database.Seed;

/// <summary>
/// Deterministic seed data (EF HasData). All demo accounts use the password "test".
/// The hash is BCrypt, the same format that the application uses at runtime.
/// </summary>
public static class SeedData
{
    private const string TestPasswordHash = "$2b$11$B5jMwgEiYbVg3qWo2Syqg.3q9pYTZ.0yAdzfYLFrOLPJE9IPuVJ/2";

    private static readonly DateTime SeedDate = new(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

    public const int AdminRoleId = 1;
    public const int ManagerRoleId = 2;
    public const int MechanicRoleId = 3;
    public const int ClientRoleId = 4;

    public static readonly Role[] Roles =
    {
        new() { Id = AdminRoleId, Name = ModelRoles.Admin, Description = "Full access to the administrative application." },
        new() { Id = ManagerRoleId, Name = ModelRoles.Manager, Description = "Manages appointments, services and reports." },
        new() { Id = MechanicRoleId, Name = ModelRoles.Mechanic, Description = "Works on vehicles and updates the service workflow." },
        new() { Id = ClientRoleId, Name = ModelRoles.Client, Description = "Vehicle owner using the mobile application." }
    };

    public static readonly City[] Cities =
    {
        new() { Id = 1, Name = "Mostar", PostalCode = "88000" },
        new() { Id = 2, Name = "Sarajevo", PostalCode = "71000" },
        new() { Id = 3, Name = "Banja Luka", PostalCode = "78000" },
        new() { Id = 4, Name = "Tuzla", PostalCode = "75000" },
        new() { Id = 5, Name = "Zenica", PostalCode = "72000" },
        new() { Id = 6, Name = "Bihać", PostalCode = "77000" },
        new() { Id = 7, Name = "Trebinje", PostalCode = "89101" },
        new() { Id = 8, Name = "Livno", PostalCode = "80101" },
        new() { Id = 9, Name = "Čapljina", PostalCode = "88300" },
        new() { Id = 10, Name = "Konjic", PostalCode = "88400" },
        new() { Id = 11, Name = "Stolac", PostalCode = "88360" },
        new() { Id = 12, Name = "Široki Brijeg", PostalCode = "88220" }
    };

    public static readonly User[] Users =
    {
        CreateUser(1, "Almedin", "Kurtić", "desktop", "desktop@autoservis.ba", "+38761000001", cityId: 1),
        CreateUser(2, "Emir", "Begić", "manager", "manager@autoservis.ba", "+38761000002", cityId: 1),
        CreateUser(3, "Adnan", "Hadžić", "mechanic", "adnan.hadzic@autoservis.ba", "+38761000003", cityId: 1),
        CreateUser(4, "Mirza", "Delić", "mirza", "mirza.delic@autoservis.ba", "+38761000004", cityId: 1),
        CreateUser(5, "Amir", "Softić", "mobile", "mobile@autoservis.ba", "+38761000005", cityId: 1),
        CreateUser(6, "Meho", "Mehić", "meho", "meho.mehic@autoservis.ba", "+38761000006", cityId: 9)
    };

    public static readonly UserRole[] UserRoles =
    {
        new() { UserId = 1, RoleId = AdminRoleId },
        new() { UserId = 2, RoleId = ManagerRoleId },
        new() { UserId = 3, RoleId = MechanicRoleId },
        new() { UserId = 4, RoleId = MechanicRoleId },
        new() { UserId = 5, RoleId = ClientRoleId },
        new() { UserId = 6, RoleId = ClientRoleId }
    };

    public static readonly VehicleBrand[] VehicleBrands = CreateBrands(
        "Audi", "BMW", "Citroën", "Dacia", "Fiat", "Ford", "Honda", "Hyundai", "Kia",
        "Mercedes-Benz", "Opel", "Peugeot", "Renault", "Seat", "Škoda", "Toyota", "Volkswagen", "Volvo");

    public static readonly ServiceCategory[] ServiceCategories =
    {
        new() { Id = 1, Name = "Regular Maintenance", Description = "Oil, filters and periodic inspections.", IsActive = true },
        new() { Id = 2, Name = "Brakes", Description = "Brake system service and replacement.", IsActive = true },
        new() { Id = 3, Name = "Computer Diagnostics", Description = "Scanning of electronic systems and sensors.", IsActive = true },
        new() { Id = 4, Name = "Air Conditioning", Description = "Climate system service and refilling.", IsActive = true },
        new() { Id = 5, Name = "Engine and Drivetrain", Description = "Engine, gearbox and exhaust system work.", IsActive = true },
        new() { Id = 6, Name = "ECU Tuning", Description = "Engine control unit optimisation.", IsActive = true }
    };

    public static readonly Hoist[] Hoists =
    {
        new() { Id = 1, Name = "Hoist 1", IsActive = true },
        new() { Id = 2, Name = "Hoist 2", IsActive = true },
        new() { Id = 3, Name = "Hoist 3", IsActive = true }
    };

    public static readonly AppointmentStatus[] AppointmentStatuses = Enum
        .GetValues<AppointmentStatusType>()
        .Select(s => new AppointmentStatus { Id = s, Name = s.ToString() })
        .ToArray();

    public static readonly ServicePhase[] ServicePhases = Enum
        .GetValues<ServicePhaseType>()
        .Select(p => new ServicePhase { Id = p, Name = p.ToString() })
        .ToArray();

    private static User CreateUser(int id, string firstName, string lastName, string username, string email, string phone, int cityId)
    {
        return new User
        {
            Id = id,
            FirstName = firstName,
            LastName = lastName,
            Username = username,
            Email = email,
            PhoneNumber = phone,
            CityId = cityId,
            PasswordHash = TestPasswordHash,
            IsActive = true,
            CreatedAt = SeedDate
        };
    }

    private static VehicleBrand[] CreateBrands(params string[] names)
    {
        return names
            .Select((name, index) => new VehicleBrand { Id = index + 1, Name = name })
            .ToArray();
    }
}
