import 'package:autoservis_desktop/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.required', () {
    test('rejects empty and blank values', () {
      final validator = Validators.required('Obavezno.');
      expect(validator(null), 'Obavezno.');
      expect(validator(''), 'Obavezno.');
      expect(validator('   '), 'Obavezno.');
    });

    test('accepts text', () {
      expect(Validators.required()('Mali servis'), isNull);
    });
  });

  group('Validators.decimal', () {
    final price = Validators.decimal(min: 0, minInclusive: false, max: 100000);

    test('accepts dot and comma as separator', () {
      expect(price('25.50'), isNull);
      expect(price('25,50'), isNull);
    });

    test('rejects zero, text and too many decimals', () {
      expect(price('0'), isNotNull);
      expect(price('abc'), isNotNull);
      expect(price('1.234'), isNotNull);
    });

    test('rejects values above the maximum', () {
      expect(price('100000.01'), isNotNull);
    });
  });

  group('Validators.integer', () {
    final duration = Validators.integer(min: 5, max: 720, multipleOf: 5);

    test('accepts a multiple of 5 in range', () {
      expect(duration('45'), isNull);
    });

    test('rejects other values', () {
      expect(duration('47'), isNotNull);
      expect(duration('0'), isNotNull);
      expect(duration('725'), isNotNull);
      expect(duration('x'), isNotNull);
    });
  });
}
