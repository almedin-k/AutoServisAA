namespace AutoServis.Model.Enums;

/// <summary>
/// Internal workshop workflow phases of a vehicle that is physically in the service.
/// </summary>
public enum ServicePhaseType
{
    Received = 1,
    DiagnosticsInProgress = 2,
    WaitingForParts = 3,
    InProgress = 4,
    Finished = 5
}
