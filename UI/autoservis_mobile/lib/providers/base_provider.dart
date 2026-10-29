import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';
import '../utils/api_client.dart';

/// Generic provider for a read-only REST resource: list with filters and paging, and get by id.
/// Clients cannot change the catalog, so there are no insert, update or delete methods here.
abstract class BaseProvider<T> with ChangeNotifier {
  BaseProvider(this.endpoint);
  final String endpoint;
  static const int maxPageSize = 100;
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

  // Loads every page of a list. Used for small reference lists like categories.
  Future<List<T>> getAll({Map<String, dynamic>? filter}) async {
    final all = <T>[];
    var page = 1;

    while (true) {
      final result = await get(filter: {...?filter, 'page': page, 'pageSize': maxPageSize});
      all.addAll(result.items);

      // The page limit protects against an endless loop if the server misbehaves.
      if (result.items.isEmpty || all.length >= result.totalCount || page >= 20) {
        return all;
      }
      page++;
    }
  }

  Future<T> getById(int id) async {
    final response = await ApiClient.send(
      () => http.get(ApiClient.buildUri('$endpoint/$id'), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);
    return fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
  }

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