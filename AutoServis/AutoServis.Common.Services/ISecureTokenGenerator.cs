namespace AutoServis.Common.Services;

public interface ISecureTokenGenerator
{
    /// <summary>Creates a cryptographically secure random token (Base64Url, no padding).</summary>
    string CreateToken(int byteLength = 64);

    /// <summary>Returns a SHA-256 hex digest. Used so raw tokens are never stored in the database.</summary>
    string Hash(string token);
}
