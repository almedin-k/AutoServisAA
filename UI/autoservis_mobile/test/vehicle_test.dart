import 'package:autoservis_mobile/models/engine_type.dart';
import 'package:autoservis_mobile/models/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Vehicle.fromJson', () {
    test('reads the response of the Vehicles API', () {
      final vehicle = Vehicle.fromJson({
        'id': 1,
        'userId': 5,
        'ownerName': 'Amir Softić',
        'brandId': 17,
        'brandName': 'Volkswagen',
        'model': 'Golf 7',
        'productionYear': 2016,
        'engineType': 'Diesel',
        'engineDisplacementCc': 1968,
        'enginePowerKw': 110,
        'vin': 'WVWZZZAUZGW123456',
        'mileageKm': 187450,
        'createdAt': '2026-01-01T00:00:00Z',
      });
      expect(vehicle.id, 1);
      expect(vehicle.title, 'Volkswagen Golf 7');
      expect(vehicle.engine, EngineType.diesel);
      expect(vehicle.mileageKm, 187450);
      expect(vehicle.vin, 'WVWZZZAUZGW123456');
    });
  });
}