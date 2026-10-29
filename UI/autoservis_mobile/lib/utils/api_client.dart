import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import 'api_client_exception.dart';

/// Shared HTTP plumbing used by every provider
class ApiClient {
  ApiClient._();
  static const Duration _timeout = Duration(seconds: 20);
  static Uri buildUri(String path, [Map<String, String>? query]) {
    final base = Uri.parse('${AppConfig.apiBaseUrl}/$path');
    if (query == null || query.isEmpty) {
      return base;
    }
    return base.replace(queryParameters: query);
  }

  static Map<String, String> headers({bool json = true}) {
    final token = AuthProvider.accessToken;
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> send(
    Future<http.Response> Function() request, {
    bool authorized = true,
  }) async {
    try {
      var response = await request().timeout(_timeout);
      if (response.statusCode == 401 && authorized && AuthProvider.hasSession) {
        if (await AuthProvider.refreshSession()) {
          response = await request().timeout(_timeout);
        }
      }
      return response;
    } on TimeoutException {
      throw ApiClientException('Server nije odgovorio na vrijeme. Pokušajte ponovo.');
    } on SocketException {
      throw ApiClientException('Nije moguće povezati se sa serverom. Provjerite vezu i pokušajte ponovo.');
    } on http.ClientException {
      throw ApiClientException('Nije moguće povezati se sa serverom. Provjerite vezu i pokušajte ponovo.');
    }
  }

  static void ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiErrorParser.fromResponse(response);
  }
  static String encodeBody(Object body) => jsonEncode(body);
  static dynamic decodeBody(http.Response response) => jsonDecode(utf8.decode(response.bodyBytes));
}