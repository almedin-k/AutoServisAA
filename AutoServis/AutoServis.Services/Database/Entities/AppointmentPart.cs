namespace AutoServis.Services.Database.Entities;

/// <summary>
/// A part that was actually used during an appointment. The unit price is a snapshot.
/// </summary>
public class AppointmentPart
{
    public int Id { get; set; }

    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    public int PartId { get; set; }
    public Part Part { get; set; } = null!;

    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}
