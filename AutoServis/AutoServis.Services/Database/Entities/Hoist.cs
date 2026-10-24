namespace AutoServis.Services.Database.Entities;

/// <summary>
/// A vehicle lift in the workshop. Together with mechanics it limits how many appointments can run at once.
/// </summary>
public class Hoist
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}
