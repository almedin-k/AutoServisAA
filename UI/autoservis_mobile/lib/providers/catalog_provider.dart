import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/service_category.dart';
import '../utils/api_client_exception.dart';
import 'service_category_provider.dart';
import 'service_provider.dart';

/// The whole (small) catalog of active categories and services, loaded once and shared by the screens.
class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._serviceProvider, this._categoryProvider);

  final ServiceProvider _serviceProvider;
  final ServiceCategoryProvider _categoryProvider;
  List<ServiceCategory> _categories = const [];
  List<Service> _services = const [];
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;
  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  List<Service> get services => _services;

  // Categories that have at least one active service. An empty category is not worth showing to a client.
  List<ServiceCategory> get categories {
    final usedIds = _services.map((service) => service.categoryId).toSet();
    return _categories.where((category) => usedIds.contains(category.id)).toList();
  }

  double? minPriceFor(int categoryId) {
    double? lowest;
    for (final service in _services) {
      if (service.categoryId == categoryId && (lowest == null || service.price < lowest)) {
        lowest = service.price;
      }
    }
    return lowest;
  }

  /// Lowest and highest price of all services. Null if the catalog is empty.
  ({double min, double max})? get priceBounds {
    if (_services.isEmpty) {
      return null;
    }

    var lowest = _services.first.price;
    var highest = _services.first.price;
    for (final service in _services) {
      if (service.price < lowest) lowest = service.price;
      if (service.price > highest) highest = service.price;
    }

    final min = lowest.floorToDouble();
    var max = highest.ceilToDouble();
    if (max <= min) {
      max = min + 1;
    }
    return (min: min, max: max);
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading || (_isLoaded && !force)) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loadedCategories = await _categoryProvider.getAll();
      final loadedServices = await _serviceProvider.getAll();
      _categories = loadedCategories;
      _services = loadedServices;
      _isLoaded = true;
    } on ApiClientException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Došlo je do neočekivane greške. Pokušajte ponovo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}