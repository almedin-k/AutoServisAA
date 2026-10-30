import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/current_user.dart';
import '../utils/api_client.dart';
import '../utils/api_client_exception.dart';

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

    if (!user.isClient) {
      await _revokeSessionOnServer();
      _clear();
      throw ApiClientException(
        'Ova aplikacija je namijenjena klijentima servisa. Osoblje koristi desktop aplikaciju.',
      );
    }
    _user = user;
    _sessionExpired = false;
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    int? cityId,
  }) async {
    final response = await ApiClient.send(
      () => http.post(
        ApiClient.buildUri('Auth/register'),
        headers: ApiClient.headers(),
        body: ApiClient.encodeBody({
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
          if (cityId != null) 'cityId': cityId,
        }),
      ),
      authorized: false,
    );
    ApiClient.ensureSuccess(response);
  }

  void applyProfile({required String firstName, required String lastName, required String email}) {
    final current = _user;
    if (current == null) {
      return;
    }
    _user = CurrentUser(
      id: current.id,
      firstName: firstName,
      lastName: lastName,
      username: current.username,
      email: email,
      roles: current.roles,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _revokeSessionOnServer();
    _clear();
    _sessionExpired = false;
    notifyListeners();
  }
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
      return false;
    }
  }

  Future<void> _revokeSessionOnServer() async {
    try {
      await http
          .post(ApiClient.buildUri('Auth/logout'), headers: ApiClient.headers())
          .timeout(const Duration(seconds: 10));
    } catch (_) {
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