using AutoServis.Model.Enums;

namespace AutoServis.Services.Database.Entities;

//Lookup table
public class AppointmentStatus
{
    public AppointmentStatusType Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
