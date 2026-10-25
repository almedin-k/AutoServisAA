using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

//Audit trail: who changed the appointment status, when and why.
public class AppointmentStatusHistory
{
    public int Id { get; set; }

    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    public AppointmentStatusType? FromStatusId { get; set; }
    public AppointmentStatusType ToStatusId { get; set; }

    // Null when the system changed the status (for example automatic cancellation).
    public int? ChangedByUserId { get; set; }
    public User? ChangedByUser { get; set; }

    public DateTime ChangedAt { get; set; }
    public string? Comment { get; set; }
}
