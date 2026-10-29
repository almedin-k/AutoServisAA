import 'dart:convert';
import 'package:http/http.dart' as http;

// An error returned by API 
class ApiClientException implements Exception {
  ApiClientException(
    this.message, {
    this.statusCode,
    Map<String, List<String>>? fieldErrors,
  }) : fieldErrors = fieldErrors ?? const {};
  final String message;
  final int? statusCode;

  // Validation messages.
  final Map<String, List<String>> fieldErrors;
  @override
  String toString() => message;
}

class ApiErrorParser {
  ApiErrorParser._();
  static const String _clientErrorKey = 'clientError';
  static const String _serverErrorKey = 'serverError';
  static ApiClientException fromResponse(http.Response response) {
    final status = response.statusCode;
    String? message;
    final fieldErrors = <String, List<String>>{};

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final root = decoded['message'];
        if (root is String && root.trim().isNotEmpty) {
          message = root.trim();
        }

        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          final all = <String>[];
          errors.forEach((key, value) {
            final messages = _messagesFrom(value);
            if (key != _clientErrorKey && key != _serverErrorKey && messages.isNotEmpty) {
              fieldErrors[key] = messages;
            }
            all.addAll(messages);
          });
          final unique = all.toSet().toList();
          if (unique.isNotEmpty) {
            message = unique.join('\n');
          }
        }
      }
    } catch (_) {
    }

    if (status == 401) {
      message ??= 'Vaša sesija je istekla. Prijavite se ponovo.';
    } else if (status == 403) {
      message ??= 'Nemate dozvolu za ovu radnju.';
    } else if (status >= 500) {
      message ??= 'Greška na serveru. Pokušajte ponovo kasnije.';
    } else {
      message ??= 'Zahtjev nije mogao biti izvršen. Pokušajte ponovo.';
    }
    return ApiClientException(message, statusCode: status, fieldErrors: fieldErrors);
  }

  static List<String> _messagesFrom(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return [];
  }
}