using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

public class Appointment
{
    public int Id { get; set; }

    public int ClientId { get; set; }
    public User Client { get; set; } = null!;

    public int VehicleId { get; set; }
    public Vehicle Vehicle { get; set; } = null!;

    public int ServiceId { get; set; }
    public Service Service { get; set; } = null!;

    public AppointmentStatusType StatusId { get; set; }
    public AppointmentStatus Status { get; set; } = null!;

    public DateTime ScheduledStart { get; set; }
    public DateTime ScheduledEnd { get; set; }

    public int? MechanicId { get; set; }
    public User? Mechanic { get; set; }

    public int? HoistId { get; set; }
    public Hoist? Hoist { get; set; }

    /// <summary>Service price in KM captured on the server when the appointment was created.</summary>
    public decimal ServicePrice { get; set; }

    public string? ClientNote { get; set; }
    public string? InternalNotes { get; set; }

    /// <summary>Diagnostic trouble codes read from the vehicle (for example P0401).</summary>
    public string? DiagnosticCodes { get; set; }

    /// <summary>After approval the client has to pay before this moment, otherwise the appointment is cancelled.</summary>
    public DateTime? PaymentDeadline { get; set; }

    public int? ApprovedByUserId { get; set; }
    public User? ApprovedByUser { get; set; }
    public DateTime? ApprovedAt { get; set; }

    public int? CancelledByUserId { get; set; }
    public User? CancelledByUser { get; set; }
    public DateTime? CancelledAt { get; set; }
    public string? CancellationReason { get; set; }

    public DateTime? CompletedAt { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }

    public ICollection<AppointmentPart> Parts { get; set; } = new List<AppointmentPart>();
    public ICollection<AppointmentStatusHistory> StatusHistory { get; set; } = new List<AppointmentStatusHistory>();
    public ICollection<ServiceWorkflow> Workflow { get; set; } = new List<ServiceWorkflow>();
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
}
