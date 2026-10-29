// 10.0.2.2 is the address under which the Android emulator reaches the computer it runs on.
// On a physical phone use the IP address of the computer in the LAN instead.
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