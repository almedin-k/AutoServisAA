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

    public string Vin { get; set; } = string.Empty;

    public int MileageKm { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime CreatedAt { get; set; }
}
