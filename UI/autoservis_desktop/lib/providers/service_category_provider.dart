import '../models/service_category.dart';
import 'base_provider.dart';

class ServiceCategoryProvider extends BaseProvider<ServiceCategory> {
  ServiceCategoryProvider() : super('ServiceCategories');

  @override
  ServiceCategory fromJson(Map<String, dynamic> json) => ServiceCategory.fromJson(json);
}
