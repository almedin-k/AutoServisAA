using AutoServis.Model.Enums;

namespace AutoServis.Model.Requests;

// Used to add or edit a vehicle. A client always works with their own vehicles.
// Staff set the owner when they add a vehicle for a client, and cannot change it afterwards.
public class VehicleUpsertRequest
{
    public int? UserId { get; set; }
    public int BrandId { get; set; }
    public string Model { get; set; } = string.Empty;
    public int ProductionYear { get; set; }
    public EngineType EngineType { get; set; }
    public int EngineDisplacementCc { get; set; }
    public int EnginePowerKw { get; set; }
    public string Vin { get; set; } = string.Empty;
    public int MileageKm { get; set; }
}