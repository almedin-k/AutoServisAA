namespace AutoServis.Services.Database.Entities;

public class Review
{
    public int Id { get; set; }

    /// <summary>One review per completed appointment (unique index).</summary>
    public int AppointmentId { get; set; }
    public Appointment Appointment { get; set; } = null!;

    public int ClientId { get; set; }
    public User Client { get; set; } = null!;

    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}
