namespace AutoServis.WebAPI.Extensions;

/// <summary>
/// Loads a .env file (searched from the working directory upwards) into environment variables.
/// Variables that already exist, for example the ones set by docker compose, are never overwritten.
/// Format: KEY=value per line, lines starting with # are comments.
/// </summary>
public static class DotEnvLoader
{
    private const string FileName = ".env";

    public static void Load()
    {
        var directory = new DirectoryInfo(Directory.GetCurrentDirectory());

        while (directory is not null)
        {
            var path = Path.Combine(directory.FullName, FileName);
            if (File.Exists(path))
            {
                Apply(path);
                return;
            }

            directory = directory.Parent;
        }
    }

    private static void Apply(string path)
    {
        foreach (var rawLine in File.ReadLines(path))
        {
            var line = rawLine.Trim();
            if (line.Length == 0 || line.StartsWith('#'))
            {
                continue;
            }

            var separatorIndex = line.IndexOf('=');
            if (separatorIndex <= 0)
            {
                continue;
            }

            var key = line[..separatorIndex].Trim();
            var value = line[(separatorIndex + 1)..].Trim().Trim('"');

            if (Environment.GetEnvironmentVariable(key) is null)
            {
                Environment.SetEnvironmentVariable(key, value);
            }
        }
    }
}
