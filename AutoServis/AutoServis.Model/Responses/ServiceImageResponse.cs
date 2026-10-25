namespace AutoServis.Model.Responses;

public class ServiceImageResponse
{
    public byte[] Data { get; set; } = Array.Empty<byte>();
    public string ContentType { get; set; } = string.Empty;
}
