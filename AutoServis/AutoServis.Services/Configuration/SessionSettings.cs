namespace AutoServis.Services.Configuration;

/// <summary>Session related settings loaded once from the environment (.env).</summary>
public record SessionSettings(int RefreshTokenDays);
