namespace AutoServis.WebAPI;

/// <summary>
/// Strongly typed application settings. Every value comes from environment variables
/// (loaded from the .env file in development), so configuration lives in exactly one place.
/// </summary>
public sealed class AppSettings
{
    private AppSettings(int apiPort, DatabaseSettings database, JwtSettings jwt, string[] corsAllowedOrigins)
    {
        ApiPort = apiPort;
        Database = database;
        Jwt = jwt;
        CorsAllowedOrigins = corsAllowedOrigins;
    }

    /// <summary>Port used when the API runs outside Docker. In Docker the container always listens on 8080.</summary>
    public int ApiPort { get; }
    public DatabaseSettings Database { get; }
    public JwtSettings Jwt { get; }
    public string[] CorsAllowedOrigins { get; }

    public static AppSettings FromConfiguration(IConfiguration configuration)
    {
        var database = new DatabaseSettings(
            Host: Required(configuration, "DB_HOST"),
            Port: RequiredInt(configuration, "DB_PORT"),
            Name: Required(configuration, "DB_NAME"),
            User: Required(configuration, "DB_USER"),
            Password: Required(configuration, "DB_PASSWORD"));

        var secretKey = Required(configuration, "JWT_SECRET_KEY");
        if (secretKey.Length < 32)
        {
            throw new InvalidOperationException("JWT_SECRET_KEY must have at least 32 characters.");
        }

        var jwt = new JwtSettings(
            SecretKey: secretKey,
            Issuer: Required(configuration, "JWT_ISSUER"),
            Audience: Required(configuration, "JWT_AUDIENCE"),
            AccessTokenMinutes: RequiredInt(configuration, "JWT_ACCESS_TOKEN_MINUTES"),
            RefreshTokenDays: RequiredInt(configuration, "JWT_REFRESH_TOKEN_DAYS"));

        var origins = (configuration["CORS_ALLOWED_ORIGINS"] ?? string.Empty)
            .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        return new AppSettings(RequiredInt(configuration, "API_PORT"), database, jwt, origins);
    }

    private static string Required(IConfiguration configuration, string key)
    {
        var value = configuration[key];
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException($"Missing required setting '{key}'. Check your .env file.");
        }

        return value;
    }

    private static int RequiredInt(IConfiguration configuration, string key)
    {
        var value = Required(configuration, key);
        if (!int.TryParse(value, out var number) || number <= 0)
        {
            throw new InvalidOperationException($"Setting '{key}' must be a positive number.");
        }

        return number;
    }
}

public sealed record DatabaseSettings(string Host, int Port, string Name, string User, string Password)
{
    public string ConnectionString =>
        $"Server={Host},{Port};Database={Name};User Id={User};Password={Password};TrustServerCertificate=True;";
}

public sealed record JwtSettings(
    string SecretKey,
    string Issuer,
    string Audience,
    int AccessTokenMinutes,
    int RefreshTokenDays);
