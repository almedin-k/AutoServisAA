import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/service.dart';
import '../utils/api_client.dart';
import 'base_provider.dart';

class ServiceProvider extends BaseProvider<Service> {
  ServiceProvider() : super('Services');
  @override
  Service fromJson(Map<String, dynamic> json) => Service.fromJson(json);

  String imageUrl(int serviceId, {int version = 0}) =>
      '${AppConfig.apiBaseUrl}/Services/$serviceId/image?v=$version';

  Future<void> uploadImage(int serviceId, Uint8List bytes, String fileName) async {
    final response = await ApiClient.send(() async {
      final request = http.MultipartRequest('PUT', ApiClient.buildUri('Services/$serviceId/image'));
      request.headers.addAll(ApiClient.headers(json: false));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
      return http.Response.fromStream(await request.send());
    });
    ApiClient.ensureSuccess(response);
  }

  Future<void> deleteImage(int serviceId) async {
    final response = await ApiClient.send(
      () => http.delete(ApiClient.buildUri('Services/$serviceId/image'), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);
  }
}
