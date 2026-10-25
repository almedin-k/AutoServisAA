using ModelRoles = AutoServis.Model.Constants.Roles;
using AutoServis.Model.Enums;
using AutoServis.Services.Database.Entities;

namespace AutoServis.Services.Database.Seed;

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

    public static readonly Part[] Parts =
    {
        new() { Id = 1, Name = "Engine oil 5W-30 (5 L)", Sku = "OIL-5W30-5L", UnitPrice = 55.00m, IsActive = true },
        new() { Id = 2, Name = "Oil filter", Sku = "FLT-OIL-STD", UnitPrice = 12.00m, IsActive = true },
        new() { Id = 3, Name = "Air filter", Sku = "FLT-AIR-STD", UnitPrice = 18.00m, IsActive = true },
        new() { Id = 4, Name = "Cabin (pollen) filter", Sku = "FLT-CAB-STD", UnitPrice = 15.00m, IsActive = true },
        new() { Id = 5, Name = "Fuel filter", Sku = "FLT-FUEL-STD", UnitPrice = 28.00m, IsActive = true },
        new() { Id = 6, Name = "Front brake pads (set)", Sku = "BRK-PAD-FR", UnitPrice = 65.00m, IsActive = true },
        new() { Id = 7, Name = "Rear brake pads (set)", Sku = "BRK-PAD-RR", UnitPrice = 55.00m, IsActive = true },
        new() { Id = 8, Name = "Front brake discs (pair)", Sku = "BRK-DSC-FR", UnitPrice = 140.00m, IsActive = true },
        new() { Id = 9, Name = "Brake fluid DOT 4 (1 L)", Sku = "BRK-FLD-1L", UnitPrice = 14.00m, IsActive = true },
        new() { Id = 10, Name = "A/C refrigerant R134a (500 g)", Sku = "AC-R134A-500", UnitPrice = 35.00m, IsActive = true },
        new() { Id = 11, Name = "Spark plug", Sku = "IGN-SPK-STD", UnitPrice = 12.00m, IsActive = true },
        new() { Id = 12, Name = "Timing belt kit", Sku = "TMG-KIT-STD", UnitPrice = 220.00m, IsActive = true },
        new() { Id = 13, Name = "Coolant (5 L)", Sku = "CLT-5L", UnitPrice = 25.00m, IsActive = true },
        new() { Id = 14, Name = "Glow plug", Sku = "IGN-GLW-STD", UnitPrice = 22.00m, IsActive = true }
    };

    public static readonly Service[] Services =
    {
        CreateService(1, 1, "Small Service", "Engine oil and oil filter replacement with a basic visual inspection of the vehicle.", 140.00m, 60, 3),
        CreateService(2, 1, "Large Service", "Oil, oil filter, air filter, cabin filter and fuel filter replacement with a full inspection of the vehicle.", 320.00m, 150, 6),
        CreateService(3, 1, "Pre-purchase Inspection", "Detailed inspection of a vehicle you plan to buy, with a written report of the findings.", 60.00m, 60, 0),
        CreateService(4, 2, "Front Brake Pads Replacement", "Replacement of the front brake pads and a check of the discs and brake lines.", 90.00m, 60, 12),
        CreateService(5, 2, "Rear Brake Pads Replacement", "Replacement of the rear brake pads and a check of the discs and handbrake.", 80.00m, 60, 12),
        CreateService(6, 2, "Front Brake Discs and Pads Replacement", "Replacement of the front brake discs together with new brake pads.", 210.00m, 120, 12),
        CreateService(7, 2, "Brake Fluid Replacement", "Complete replacement of the brake fluid and bleeding of the brake system.", 55.00m, 45, 6),
        CreateService(8, 3, "Complete Computer Diagnostics", "Scanning of all electronic control units, reading of fault codes and live sensor data, with a written report.", 50.00m, 45, 0),
        CreateService(9, 3, "Fault Code Reading and Reset", "Quick reading and clearing of fault codes with an explanation of what each code means.", 25.00m, 20, 0),
        CreateService(10, 4, "Air Conditioning Service and Refill", "Leak check, refrigerant refill and cabin filter replacement for an efficient climate system.", 90.00m, 60, 6),
        CreateService(11, 4, "Air Conditioning Disinfection", "Cleaning and disinfection of the climate system to remove bacteria and unpleasant odours.", 45.00m, 30, 0),
        CreateService(12, 5, "Timing Belt Replacement", "Replacement of the timing belt kit and coolant, including a check of the related components.", 280.00m, 240, 12),
        CreateService(13, 5, "Coolant Replacement", "Draining and refilling of the cooling system with new coolant.", 70.00m, 60, 6),
        CreateService(14, 5, "Spark Plug Replacement", "Replacement of the spark plugs on petrol engines.", 60.00m, 45, 6),
        CreateService(15, 6, "ECU Remap Stage 1", "Optimisation of the engine control unit software for better response and efficiency, with a before and after test.", 450.00m, 180, 12),
        CreateService(16, 6, "ECU Reading and Backup", "Reading of the original ECU software and storing a backup, so the vehicle can always be returned to stock.", 100.00m, 60, 0)
    };

    public static readonly ServicePart[] ServiceParts =
    {
        new() { ServiceId = 1, PartId = 1, Quantity = 1 },
        new() { ServiceId = 1, PartId = 2, Quantity = 1 },
        new() { ServiceId = 2, PartId = 1, Quantity = 1 },
        new() { ServiceId = 2, PartId = 2, Quantity = 1 },
        new() { ServiceId = 2, PartId = 3, Quantity = 1 },
        new() { ServiceId = 2, PartId = 4, Quantity = 1 },
        new() { ServiceId = 2, PartId = 5, Quantity = 1 },
        new() { ServiceId = 4, PartId = 6, Quantity = 1 },
        new() { ServiceId = 5, PartId = 7, Quantity = 1 },
        new() { ServiceId = 6, PartId = 6, Quantity = 1 },
        new() { ServiceId = 6, PartId = 8, Quantity = 1 },
        new() { ServiceId = 7, PartId = 9, Quantity = 2 },
        new() { ServiceId = 10, PartId = 4, Quantity = 1 },
        new() { ServiceId = 10, PartId = 10, Quantity = 1 },
        new() { ServiceId = 12, PartId = 12, Quantity = 1 },
        new() { ServiceId = 12, PartId = 13, Quantity = 1 },
        new() { ServiceId = 13, PartId = 13, Quantity = 1 },
        new() { ServiceId = 14, PartId = 11, Quantity = 4 }
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

    private static Service CreateService(
        int id, int categoryId, string name, string description, decimal price, int durationMinutes, int warrantyMonths)
    {
        return new Service
        {
            Id = id,
            CategoryId = categoryId,
            Name = name,
            Description = description,
            Price = price,
            DurationMinutes = durationMinutes,
            WarrantyMonths = warrantyMonths,
            IsActive = true,
            HasImage = false,
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
