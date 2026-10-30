import '../models/vehicle_brand.dart';
import 'base_provider.dart';

// Vehicle brands for the dropdown.
class VehicleBrandProvider extends BaseProvider<VehicleBrand> {
  VehicleBrandProvider() : super('VehicleBrands');
  List<VehicleBrand>? _cache;
  @override
  VehicleBrand fromJson(Map<String, dynamic> json) => VehicleBrand.fromJson(json);
  Future<List<VehicleBrand>> loadAll() async {
    return _cache ??= await getAll();
  }
}