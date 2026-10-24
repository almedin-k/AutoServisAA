using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

/// <summary>
/// Audit trail: who changed the appointment status, when and why.
/// </summary>
public class AppointmentStatusHistory
{
    public int Id { get; set; }

    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    public AppointmentStatusType? FromStatusId { get; set; }
    public AppointmentStatusType ToStatusId { get; set; }

    /// <summary>Null when the system changed the status (for example automatic cancellation).</summary>
    public int? ChangedByUserId { get; set; }
    public User? ChangedByUser { get; set; }

    public DateTime ChangedAt { get; set; }
    public string? Comment { get; set; }
}
