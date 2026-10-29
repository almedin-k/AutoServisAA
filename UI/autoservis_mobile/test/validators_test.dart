import 'package:autoservis_mobile/utils/validators.dart';
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
      expect(Validators.required()('Amir'), isNull);
    });
  });

  group('Validators.username', () {
    final validator = Validators.username();

    test('accepts letters, digits, dot, underscore and dash', () {
      expect(validator('mobile'), isNull);
      expect(validator('amir.softic_01'), isNull);
    });

    test('rejects short names, spaces and other characters', () {
      expect(validator(''), isNotNull);
      expect(validator('ab'), isNotNull);
      expect(validator('amir softic'), isNotNull);
      expect(validator('amir@softic'), isNotNull);
    });
  });

  group('Validators.email', () {
    final validator = Validators.email();

    test('accepts a normal address', () {
      expect(validator('ime@primjer.ba'), isNull);
    });

    test('rejects an address without a domain', () {
      expect(validator(''), isNotNull);
      expect(validator('ime'), isNotNull);
      expect(validator('ime@primjer'), isNotNull);
    });
  });

  group('Validators.password', () {
    final validator = Validators.password();

    test('needs 8 characters with a letter and a digit', () {
      expect(validator('lozinka1'), isNull);
      expect(validator('lozinka'), isNotNull);
      expect(validator('12345678'), isNotNull);
      expect(validator('abc1'), isNotNull);
      expect(validator(''), isNotNull);
    });
  });

  group('Validators.sameAs', () {
    test('compares with the current value of the other field', () {
      var other = 'lozinka1';
      final validator = Validators.sameAs(() => other, 'Ne podudara se.');

      expect(validator('lozinka1'), isNull);
      expect(validator('lozinka2'), 'Ne podudara se.');

      other = 'lozinka2';
      expect(validator('lozinka2'), isNull);
    });
  });

  group('Validators.optionalPhone', () {
    final validator = Validators.optionalPhone();

    test('empty value is valid', () {
      expect(validator(null), isNull);
      expect(validator(''), isNull);
    });

    test('checks the format when a value is entered', () {
      expect(validator('+38761123456'), isNull);
      expect(validator('061 123 456'), isNull);
      expect(validator('abc'), isNotNull);
      expect(validator('123'), isNotNull);
    });
  });

  group('Validators.compose', () {
    test('returns the first message', () {
      final validator = Validators.compose([
        Validators.required('Prvo.'),
        Validators.maxLength(3, 'Drugo.'),
      ]);

      expect(validator(''), 'Prvo.');
      expect(validator('abcd'), 'Drugo.');
      expect(validator('abc'), isNull);
    });
  });
}
