using ModelRoles = AutoServis.Model.Constants.Roles;
using AutoServis.Model.Enums;
using AutoServis.Services.Database.Entities;

namespace AutoServis.Services.Database.Seed;

// Deterministic seed data. All demo accounts use the password "test". The hash is BCrypt.
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
        CreateUser(1, "Almedin", "Kurtić", "desktop", "desktop@autoservis.ba", "+38761000001", cityId: 2),
        CreateUser(2, "Emir", "Begić", "manager", "manager@autoservis.ba", "+38761000002", cityId: 1),
        CreateUser(3, "Adnan", "Hadžić", "mechanic", "adnan.hadzic@autoservis.ba", "+38761000003", cityId: 3),
        CreateUser(4, "Mirza", "Delić", "mobile", "mobile@autoservis.ba", "+38761000004", cityId: 5),
        CreateUser(5, "Amir", "Softić", "amir", "amir@autoservis.ba", "+38761000005", cityId: 7),
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
        new() { Id = 1, Name = "Redovno održavanje", Description = "Ulje, filteri i periodični pregledi.", IsActive = true },
        new() { Id = 2, Name = "Kočioni sistem", Description = "Servis i zamjena dijelova kočionog sistema.", IsActive = true },
        new() { Id = 3, Name = "Kompjuterska dijagnostika", Description = "Očitavanje elektronskih sistema i senzora.", IsActive = true },
        new() { Id = 4, Name = "Klima uređaj", Description = "Servis i punjenje klima uređaja.", IsActive = true },
        new() { Id = 5, Name = "Motor i pogonski mehanizam", Description = "Radovi na motoru, mjenjaču i izduvnom sistemu.", IsActive = true },
        new() { Id = 6, Name = "ECU tuning", Description = "Optimizacija softvera upravljačke jedinice motora.", IsActive = true }
    };

    public static readonly Hoist[] Hoists =
    {
        new() { Id = 1, Name = "Dizalica 1", IsActive = true },
        new() { Id = 2, Name = "Dizalica 2", IsActive = true },
        new() { Id = 3, Name = "Dizalica 3", IsActive = true }
    };

    public static readonly Part[] Parts =
    {
        new() { Id = 1, Name = "Motorno ulje 5W-30 (5 L)", Sku = "OIL-5W30-5L", UnitPrice = 108.00m, IsActive = true },
        new() { Id = 2, Name = "Filter ulja", Sku = "FLT-OIL-STD", UnitPrice = 12.00m, IsActive = true },
        new() { Id = 3, Name = "Filter zraka", Sku = "FLT-AIR-STD", UnitPrice = 18.00m, IsActive = true },
        new() { Id = 4, Name = "Polenski (kabinski) filter", Sku = "FLT-CAB-STD", UnitPrice = 15.00m, IsActive = true },
        new() { Id = 5, Name = "Filter goriva", Sku = "FLT-FUEL-STD", UnitPrice = 28.00m, IsActive = true },
        new() { Id = 6, Name = "Prednje kočione pločice (komplet)", Sku = "BRK-PAD-FR", UnitPrice = 65.00m, IsActive = true },
        new() { Id = 7, Name = "Zadnje kočione pločice (komplet)", Sku = "BRK-PAD-RR", UnitPrice = 55.00m, IsActive = true },
        new() { Id = 8, Name = "Prednji kočioni diskovi (par)", Sku = "BRK-DSC-FR", UnitPrice = 140.00m, IsActive = true },
        new() { Id = 9, Name = "Kočiona tečnost DOT 4 (1 L)", Sku = "BRK-FLD-1L", UnitPrice = 14.00m, IsActive = true },
        new() { Id = 10, Name = "Klima plin R134a (500 g)", Sku = "AC-R134A-500", UnitPrice = 35.00m, IsActive = true },
        new() { Id = 11, Name = "Svjećica", Sku = "IGN-SPK-STD", UnitPrice = 12.00m, IsActive = true },
        new() { Id = 12, Name = "Set zupčastog remena", Sku = "TMG-KIT-STD", UnitPrice = 270.00m, IsActive = true },
        new() { Id = 13, Name = "Rashladna tečnost (5 L)", Sku = "CLT-5L", UnitPrice = 35.00m, IsActive = true },
        new() { Id = 14, Name = "Grijač", Sku = "IGN-GLW-STD", UnitPrice = 22.00m, IsActive = true }
    };

    // The service price covers labour. Parts are charged separately, based on what is actually used.
    public static readonly Service[] Services =
    {
        CreateService(1, 1, "Mali servis", "Zamjena motornog ulja i filtera ulja uz osnovnu vizuelnu kontrolu vozila.", 140.00m, 60, 3),
        CreateService(2, 1, "Veliki servis", "Zamjena ulja, filtera ulja, zraka, polena i goriva uz kompletan pregled vozila.", 320.00m, 150, 6),
        CreateService(3, 1, "Pregled vozila prije kupovine", "Detaljan pregled vozila koje planirate kupiti, uz pisani izvještaj o nalazima.", 60.00m, 60, 0),
        CreateService(4, 2, "Zamjena prednjih kočionih pločica", "Zamjena prednjih kočionih pločica uz kontrolu diskova i kočionih cijevi.", 90.00m, 60, 12),
        CreateService(5, 2, "Zamjena zadnjih kočionih pločica", "Zamjena zadnjih kočionih pločica uz kontrolu diskova i ručne kočnice.", 80.00m, 60, 12),
        CreateService(6, 2, "Zamjena prednjih diskova i pločica", "Zamjena prednjih kočionih diskova zajedno s novim pločicama.", 210.00m, 120, 12),
        CreateService(7, 2, "Zamjena kočione tečnosti", "Potpuna zamjena kočione tečnosti i odzračivanje kočionog sistema.", 55.00m, 45, 6),
        CreateService(8, 3, "Kompletna kompjuterska dijagnostika", "Očitavanje svih elektronskih upravljačkih jedinica, kodova grešaka i parametara senzora, uz pisani izvještaj.", 50.00m, 45, 0),
        CreateService(9, 3, "Očitavanje i brisanje kodova grešaka", "Brzo očitavanje i brisanje kodova grešaka uz objašnjenje šta pojedini kod znači.", 25.00m, 20, 0),
        CreateService(10, 4, "Servis i punjenje klime", "Provjera curenja, punjenje klima plina i zamjena polenskog filtera za efikasan rad klima uređaja.", 90.00m, 60, 6),
        CreateService(11, 4, "Dezinfekcija klima uređaja", "Čišćenje i dezinfekcija klima sistema radi uklanjanja bakterija i neugodnih mirisa.", 45.00m, 30, 0),
        CreateService(12, 5, "Zamjena zupčastog remena", "Zamjena seta zupčastog remena i rashladne tečnosti uz provjeru povezanih komponenti.", 280.00m, 240, 12),
        CreateService(13, 5, "Zamjena rashladne tečnosti", "Ispuštanje i punjenje rashladnog sistema novom rashladnom tečnošću.", 70.00m, 60, 6),
        CreateService(14, 5, "Zamjena svjećica", "Zamjena svjećica na benzinskim motorima.", 60.00m, 45, 6),
        CreateService(15, 6, "ECU optimizacija (Stage 1)", "Optimizacija softvera upravljačke jedinice motora za bolji odziv i potrošnju, uz test prije i poslije.", 450.00m, 180, 12),
        CreateService(16, 6, "Očitavanje i sigurnosna kopija ECU-a", "Očitavanje originalnog softvera ECU-a i čuvanje kopije, kako bi se vozilo uvijek moglo vratiti na tvorničko stanje.", 100.00m, 60, 0)
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
