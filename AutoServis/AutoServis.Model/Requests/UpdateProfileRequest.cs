namespace AutoServis.Model.Requests;

// Profile data the signed-in user can change. The username cannot be changed.
public class UpdateProfileRequest
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public int? CityId { get; set; }
}