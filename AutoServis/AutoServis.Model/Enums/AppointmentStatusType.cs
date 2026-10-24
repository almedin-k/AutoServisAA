namespace AutoServis.Model.Enums;

/// <summary>
/// Appointment lifecycle. Allowed transitions are defined in the appointment state machine.
/// </summary>
public enum AppointmentStatusType
{
    Pending = 1,
    Approved = 2,
    Confirmed = 3,
    Completed = 4,
    Cancelled = 5
}
