using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

public class ServicePhase
{
    public ServicePhaseType Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
