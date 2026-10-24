using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

/// <summary>
/// One entry of the internal workshop workflow. The latest entry is the current phase.
/// </summary>
public class ServiceWorkflow
{
    public int Id { get; set; }

    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    public ServicePhaseType PhaseId { get; set; }
    public ServicePhase Phase { get; set; } = null!;

    public int ChangedByUserId { get; set; }
    public User ChangedByUser { get; set; } = null!;

    public DateTime ChangedAt { get; set; }
    public string? Note { get; set; }
}
