import 'package:http/http.dart' as http;
import '../models/engine_type.dart';
import '../models/vehicle.dart';
import '../utils/api_client.dart';
import '../utils/api_client_exception.dart';
import 'base_provider.dart';

// The garage of the signed-in client. The list is loaded once and shared by the screens
class VehicleProvider extends BaseProvider<Vehicle> {
  VehicleProvider() : super('Vehicles');
  List<Vehicle> _vehicles = const [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;
  int _generation = 0;
  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  @override
  Vehicle fromJson(Map<String, dynamic> json) => Vehicle.fromJson(json);
  Future<void> load({bool force = false}) async {
    if (_isLoading || (_isLoaded && !force)) {
      return;
    }
    final generation = _generation;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await getAll();
      if (generation != _generation) {
        return;
      }
      _vehicles = loaded;
      _isLoaded = true;
    } on ApiClientException catch (e) {
      if (generation == _generation) {
        _error = e.message;
      }
    } catch (_) {
      if (generation == _generation) {
        _error = 'Došlo je do neočekivane greške. Pokušajte ponovo.';
      }
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
  Future<Vehicle> save({
    int? id,
    required int brandId,
    required String model,
    required int productionYear,
    required EngineType engineType,
    required int engineDisplacementCc,
    required int enginePowerKw,
    required String vin,
    required int mileageKm,
  }) async {
    final body = ApiClient.encodeBody({
      'brandId': brandId,
      'model': model,
      'productionYear': productionYear,
      'engineType': engineType.apiName,
      'engineDisplacementCc': engineDisplacementCc,
      'enginePowerKw': enginePowerKw,
      'vin': vin,
      'mileageKm': mileageKm,
    });

    final response = await ApiClient.send(
      () => id == null
          ? http.post(ApiClient.buildUri('Vehicles'), headers: ApiClient.headers(), body: body)
          : http.put(ApiClient.buildUri('Vehicles/$id'), headers: ApiClient.headers(), body: body),
    );
    ApiClient.ensureSuccess(response);
    final saved = Vehicle.fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
    final updated = [..._vehicles];
    final index = updated.indexWhere((vehicle) => vehicle.id == saved.id);
    if (index >= 0) {
      updated[index] = saved;
    } else {
      updated.add(saved);
    }
    _vehicles = _sorted(updated);
    notifyListeners();
    return saved;
  }

  Future<void> remove(int id) async {
    final response = await ApiClient.send(
      () => http.delete(ApiClient.buildUri('Vehicles/$id'), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);
    _vehicles = _vehicles.where((vehicle) => vehicle.id != id).toList();
    notifyListeners();
  }

  void clear() {
    _generation++;
    _vehicles = const [];
    _isLoading = false;
    _isLoaded = false;
    _error = null;
    notifyListeners();
  }

  // The same order as the API uses: brand, model.
  List<Vehicle> _sorted(List<Vehicle> list) {
    list.sort((a, b) {
      final byBrand = a.brandName.toLowerCase().compareTo(b.brandName.toLowerCase());
      if (byBrand != 0) {
        return byBrand;
      }
      final byModel = a.model.toLowerCase().compareTo(b.model.toLowerCase());
      return byModel != 0 ? byModel : a.id.compareTo(b.id);
    });
    return list;
  }
}