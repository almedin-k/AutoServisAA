// Build-time configuration.
class AppConfig {
  AppConfig._();

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured => _apiBaseUrl.trim().isNotEmpty;

  // API address without a trailing slash.
  static String get apiBaseUrl {
    final value = _apiBaseUrl.trim();
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
