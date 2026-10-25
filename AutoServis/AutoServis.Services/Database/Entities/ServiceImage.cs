namespace AutoServis.Services.Database.Entities;

public class ServiceImage
{
    public int ServiceId { get; set; }
    public Service Service { get; set; } = null!;

    public byte[] Data { get; set; } = Array.Empty<byte>();
    public string ContentType { get; set; } = string.Empty;
}
