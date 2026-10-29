import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/city.dart';
import '../utils/api_client.dart';

/// Cities for the registration form. The endpoint is public, because the user has no account yet.
class CityProvider with ChangeNotifier {
  Future<List<City>> lookup() async {
    final response = await ApiClient.send(
      () => http.get(ApiClient.buildUri('Cities/lookup'), headers: ApiClient.headers()),
      authorized: false,
    );
    ApiClient.ensureSuccess(response);
    final data = ApiClient.decodeBody(response) as List;
    return data.map((item) => City.fromJson(item as Map<String, dynamic>)).toList();
  }
}