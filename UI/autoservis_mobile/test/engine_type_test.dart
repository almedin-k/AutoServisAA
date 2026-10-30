import 'package:autoservis_mobile/models/engine_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EngineType', () {
    test('api names match the values of the API enum', () {
      expect(EngineType.petrol.apiName, 'Petrol');
      expect(EngineType.diesel.apiName, 'Diesel');
      expect(EngineType.hybrid.apiName, 'Hybrid');
      expect(EngineType.electric.apiName, 'Electric');
      expect(EngineType.lpg.apiName, 'Lpg');
    });

    test('fromApi finds the type and falls back to petrol', () {
      expect(EngineType.fromApi('Diesel'), EngineType.diesel);
      expect(EngineType.fromApi('Electric'), EngineType.electric);
      expect(EngineType.fromApi('Hydrogen'), EngineType.petrol);
      expect(EngineType.fromApi(null), EngineType.petrol);
    });

    test('labels are in Bosnian', () {
      expect(EngineType.petrol.label, 'Benzin');
      expect(EngineType.diesel.label, 'Dizel');
      expect(EngineType.hybrid.label, 'Hibrid');
    });
  });
}