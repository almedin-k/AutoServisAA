using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

/// <summary>Lookup table. Ids are the values of <see cref="ServicePhaseType"/>.</summary>
public class ServicePhase
{
    public ServicePhaseType Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
