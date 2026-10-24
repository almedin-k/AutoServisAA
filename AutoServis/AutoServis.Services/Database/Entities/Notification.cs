using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

public class Notification
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public NotificationType Type { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }

    public int? AppointmentId { get; set; }
    public Appointment? Appointment { get; set; }
}
