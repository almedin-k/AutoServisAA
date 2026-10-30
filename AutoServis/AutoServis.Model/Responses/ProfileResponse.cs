namespace AutoServis.Model.Responses;

public class ProfileResponse
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public int? CityId { get; set; }
    public string? CityName { get; set; }
    public bool HasProfileImage { get; set; }
    public DateTime CreatedAt { get; set; }
}