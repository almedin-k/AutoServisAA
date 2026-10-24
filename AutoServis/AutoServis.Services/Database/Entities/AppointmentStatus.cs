using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

/// <summary>Lookup table. Ids are the values of <see cref="AppointmentStatusType"/>.</summary>
public class AppointmentStatus
{
    public AppointmentStatusType Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
