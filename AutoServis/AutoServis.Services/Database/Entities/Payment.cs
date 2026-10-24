using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

public class Payment
{
    public int Id { get; set; }

    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    /// <summary>Amount in KM that the client owes for the appointment.</summary>
    public decimal Amount { get; set; }

    /// <summary>Amount actually charged by the payment provider (the provider may not support KM).</summary>
    public decimal ChargedAmount { get; set; }
    public string ChargedCurrency { get; set; } = string.Empty;

    public string ExternalOrderId { get; set; } = string.Empty;
    public string? ExternalCaptureId { get; set; }

    public PaymentStatus Status { get; set; }

    /// <summary>Refunds are based on the amount that was really charged.</summary>
    public decimal? RefundedAmount { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? PaidAt { get; set; }
    public DateTime? RefundedAt { get; set; }
}
