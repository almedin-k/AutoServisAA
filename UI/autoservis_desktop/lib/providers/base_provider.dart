import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';
import '../utils/api_client.dart';

// Generic provider for a REST resource: list with filters and paging, get by id, insert, update, delete.
abstract class BaseProvider<T> with ChangeNotifier {
  BaseProvider(this.endpoint);

  // API resource segment, for example "Services".
  final String endpoint;

  T fromJson(Map<String, dynamic> json);

  Future<SearchResult<T>> get({Map<String, dynamic>? filter}) async {
    final response = await ApiClient.send(
      () => http.get(ApiClient.buildUri(endpoint, _toQuery(filter)), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);

    final data = ApiClient.decodeBody(response) as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();

    return SearchResult<T>(
      items: items,
      totalCount: data['totalCount'] as int,
      page: data['page'] as int,
      pageSize: data['pageSize'] as int,
    );
  }

  Future<T> getById(int id) async {
    final response = await ApiClient.send(
      () => http.get(ApiClient.buildUri('$endpoint/$id'), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);

    return fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
  }

  Future<T> insert(Map<String, dynamic> request) async {
    final response = await ApiClient.send(
      () => http.post(
        ApiClient.buildUri(endpoint),
        headers: ApiClient.headers(),
        body: ApiClient.encodeBody(request),
      ),
    );
    ApiClient.ensureSuccess(response);

    return fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
  }

  Future<T> update(int id, Map<String, dynamic> request) async {
    final response = await ApiClient.send(
      () => http.put(
        ApiClient.buildUri('$endpoint/$id'),
        headers: ApiClient.headers(),
        body: ApiClient.encodeBody(request),
      ),
    );
    ApiClient.ensureSuccess(response);

    return fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
  }

  Future<void> remove(int id) async {
    final response = await ApiClient.send(
      () => http.delete(ApiClient.buildUri('$endpoint/$id'), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);
  }

  // Turns the filter map into query parameters. Null and empty values are skipped.
  Map<String, String>? _toQuery(Map<String, dynamic>? filter) {
    if (filter == null) {
      return null;
    }

    final query = <String, String>{};
    filter.forEach((key, value) {
      if (value == null) {
        return;
      }
      final text = value.toString();
      if (text.isNotEmpty) {
        query[key] = text;
      }
    });

    return query;
  }
}
