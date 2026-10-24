namespace AutoServis.Services.Database.Entities;

/// <summary>
/// Recorded every time a user opens a service. It is a real input signal for the recommender.
/// </summary>
public class ServiceView
{
    public long Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int ServiceId { get; set; }
    public Service Service { get; set; } = null!;

    public DateTime ViewedAt { get; set; }
}
