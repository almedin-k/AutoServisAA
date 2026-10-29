import '../config/app_config.dart';
import '../models/service.dart';
import 'base_provider.dart';

class ServiceProvider extends BaseProvider<Service> {
  ServiceProvider() : super('Services');
  @override
  Service fromJson(Map<String, dynamic> json) => Service.fromJson(json);
  String imageUrl(int serviceId, {int version = 0}) => '${AppConfig.apiBaseUrl}/Services/$serviceId/image?v=$version';
}