namespace AutoServis.Services.Database.Entities;

public class User
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }

    public int? CityId { get; set; }
    public City? City { get; set; }

    public byte[]? ProfileImage { get; set; }
    public string? ProfileImageContentType { get; set; }

    /// <summary>Soft delete flag. Inactive users cannot sign in but their history is preserved.</summary>
    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }

    /// <summary>
    /// Intentionally has no initializer: EF Core does not allow seed (HasData) entities with navigation collections set.
    /// Always use Include(u => u.UserRoles) when reading, or assign a new list when creating a user.
    /// </summary>
    public ICollection<UserRole> UserRoles { get; set; } = null!;
}
