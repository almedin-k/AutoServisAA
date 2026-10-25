using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

public class Payment
{
    public int Id { get; set; }

    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    public decimal Amount { get; set; }

    public decimal ChargedAmount { get; set; }
    public string ChargedCurrency { get; set; } = string.Empty;

    public string ExternalOrderId { get; set; } = string.Empty;
    public string? ExternalCaptureId { get; set; }

    public PaymentStatus Status { get; set; }

    public decimal? RefundedAmount { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? RefundedAt { get; set; }
}
