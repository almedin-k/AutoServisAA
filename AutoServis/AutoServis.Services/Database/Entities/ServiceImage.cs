namespace AutoServis.Services.Database.Entities;

/// <summary>
/// Image binary kept in its own table so service lists never load image data.
/// </summary>
public class ServiceImage
{
    public int ServiceId { get; set; }
    public Service Service { get; set; } = null!;

    public byte[] Data { get; set; } = Array.Empty<byte>();
    public string ContentType { get; set; } = string.Empty;
}
