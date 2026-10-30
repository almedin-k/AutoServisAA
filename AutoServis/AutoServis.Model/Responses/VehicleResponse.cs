using AutoServis.Model.Enums;

namespace AutoServis.Model.Responses;

public class VehicleResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string OwnerName { get; set; } = string.Empty;
    public int BrandId { get; set; }
    public string BrandName { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
    public int ProductionYear { get; set; }
    public EngineType EngineType { get; set; }
    public int EngineDisplacementCc { get; set; }
    public int EnginePowerKw { get; set; }
    public string Vin { get; set; } = string.Empty;
    public int MileageKm { get; set; }
    public DateTime CreatedAt { get; set; }
}