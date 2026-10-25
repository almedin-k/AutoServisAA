namespace AutoServis.Services.Catalog;

/// Detects the real image format from the first bytes of a file. The content type sent by the client is never trusted.
internal static class ImageSignature
{
    public static string? Detect(ReadOnlySpan<byte> data)
    {
        if (data.Length >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF)
        {
            return "image/jpeg";
        }

        ReadOnlySpan<byte> png = stackalloc byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A };
        if (data.Length >= png.Length && data[..png.Length].SequenceEqual(png))
        {
            return "image/png";
        }

        // WebP: "RIFF" + 4 size bytes + "WEBP"
        if (data.Length >= 12
            && data[0] == (byte)'R' && data[1] == (byte)'I' && data[2] == (byte)'F' && data[3] == (byte)'F'
            && data[8] == (byte)'W' && data[9] == (byte)'E' && data[10] == (byte)'B' && data[11] == (byte)'P')
        {
            return "image/webp";
        }

        return null;
    }
}
