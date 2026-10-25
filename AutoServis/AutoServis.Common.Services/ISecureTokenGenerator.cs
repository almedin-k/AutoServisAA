namespace AutoServis.Common.Services;

public interface ISecureTokenGenerator
{
    string CreateToken(int byteLength = 64);
    string Hash(string token);
}
