namespace AutoServis.Services.Database.Entities;

// Server-side session. The row id is the "sid" claim of the access token.  Only the SHA-256 hash of the refresh token is stored.
public class RefreshToken
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public string TokenHash { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime? RevokedAt { get; set; }
}
