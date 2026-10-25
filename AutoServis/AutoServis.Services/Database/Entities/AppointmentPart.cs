namespace AutoServis.Services.Database.Entities;

// A part that was actually used during an appointment. The unit price is a snapshot.
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
