using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

public class Vehicle
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int BrandId { get; set; }
    public VehicleBrand Brand { get; set; } = null!;

    public string Model { get; set; } = string.Empty;
    public int ProductionYear { get; set; }
    public EngineType EngineType { get; set; }
    public int EngineDisplacementCc { get; set; }
    public int EnginePowerKw { get; set; }

    /// <summary>Vehicle identification number, exactly 17 characters.</summary>
    public string Vin { get; set; } = string.Empty;

    public int MileageKm { get; set; }

    /// <summary>Logical delete so that service history stays linked to the vehicle.</summary>
    public bool IsDeleted { get; set; }

    public DateTime CreatedAt { get; set; }
}
