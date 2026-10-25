namespace AutoServis.Common.Services;

/// <summary>
/// BCrypt password hashing. The salt is generated and embedded in the hash by BCrypt.
/// </summary>
public class PasswordHasher : IPasswordHasher
{
    private const int WorkFactor = 11;
    public string Hash(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password, WorkFactor);
    }
    public bool Verify(string password, string passwordHash)
    {
        return BCrypt.Net.BCrypt.Verify(password, passwordHash);
    }
}
