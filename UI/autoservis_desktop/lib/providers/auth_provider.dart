import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/current_user.dart';
import '../utils/api_client.dart';
import '../utils/api_client_exception.dart';

// Holds the signed-in user and the tokens. The tokens are kept in memory only, they are never written to disk.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _instance = this;
  }

  static AuthProvider? _instance;
  static String? _accessToken;
  static String? _refreshToken;
  static Future<bool>? _refreshing;

  CurrentUser? _user;
  bool _sessionExpired = false;

  static String? get accessToken => _accessToken;

  static bool get hasSession => _accessToken != null && _refreshToken != null;

  CurrentUser? get user => _user;

  bool get isAuthenticated => _user != null;

  bool get isStaff => _user?.isStaff ?? false;

  // True once after the session ended because the refresh token was no longer valid.
  bool consumeSessionExpired() {
    final expired = _sessionExpired;
    _sessionExpired = false;
    return expired;
  }

  Future<void> login(String username, String password) async {
    final response = await ApiClient.send(
      () => http.post(
        ApiClient.buildUri('Auth/login'),
        headers: ApiClient.headers(),
        body: ApiClient.encodeBody({'username': username, 'password': password}),
      ),
      authorized: false,
    );
    ApiClient.ensureSuccess(response);

    final data = ApiClient.decodeBody(response) as Map<String, dynamic>;
    final user = CurrentUser.fromJson(data['user'] as Map<String, dynamic>);

    _accessToken = data['accessToken'] as String;
    _refreshToken = data['refreshToken'] as String;

    if (!user.canUseDesktop) {
      // The credentials are correct, but clients must use the mobile application.
      await _revokeSessionOnServer();
      _clear();
      throw ApiClientException(
        'Ova aplikacija je namijenjena samo osoblju servisa. Koristite mobilnu aplikaciju.',
      );
    }

    _user = user;
    _sessionExpired = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _revokeSessionOnServer();
    _clear();
    _sessionExpired = false;
    notifyListeners();
  }

  // Gets a new access token with the refresh token. Parallel callers share one refresh request. Returns false when the session cannot be continued.
  static Future<bool> refreshSession() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  static Future<bool> _doRefresh() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await http
          .post(
            ApiClient.buildUri('Auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: ApiClient.encodeBody({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = ApiClient.decodeBody(response) as Map<String, dynamic>;
        _accessToken = data['accessToken'] as String;
        _refreshToken = data['refreshToken'] as String;
        return true;
      }

      if (response.statusCode == 400 || response.statusCode == 401) {
        _instance?._expire();
      }
      return false;
    } catch (_) {
      // A network problem does not end the session, the user can simply try again.
      return false;
    }
  }

  Future<void> _revokeSessionOnServer() async {
    try {
      await http
          .post(ApiClient.buildUri('Auth/logout'), headers: ApiClient.headers())
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // The local session is removed anyway. The token also expires on its own.
    }
  }

  void _expire() {
    _clear();
    _sessionExpired = true;
    notifyListeners();
  }

  void _clear() {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
  }
}
