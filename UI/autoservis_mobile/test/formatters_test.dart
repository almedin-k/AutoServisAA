import 'package:autoservis_mobile/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney', () {
    test('uses decimal comma and KM', () {
      expect(formatMoney(150), '150,00 KM');
      expect(formatMoney(25.5), '25,50 KM');
    });

    test('uses a dot as the thousands separator', () {
      expect(formatMoney(1234.5), '1.234,50 KM');
      expect(formatMoney(1234567.89), '1.234.567,89 KM');
    });
  });

  group('pluralBs', () {
    String months(int n) => pluralBs(n, 'mjesec', 'mjeseca', 'mjeseci');

    test('picks the Bosnian form of the word', () {
      expect(months(1), 'mjesec');
      expect(months(2), 'mjeseca');
      expect(months(4), 'mjeseca');
      expect(months(5), 'mjeseci');
      expect(months(11), 'mjeseci');
      expect(months(12), 'mjeseci');
      expect(months(21), 'mjesec');
      expect(months(22), 'mjeseca');
    });
  });

  group('formatWarranty', () {
    test('handles no warranty and plural forms', () {
      expect(formatWarranty(0), 'Bez garancije');
      expect(formatWarranty(1), '1 mjesec');
      expect(formatWarranty(3), '3 mjeseca');
      expect(formatWarranty(12), '12 mjeseci');
    });
  });

  group('formatDuration', () {
    test('shows minutes below one hour and hours above', () {
      expect(formatDuration(45), '~45 min');
      expect(formatDuration(60), '~1 h');
      expect(formatDuration(150), '~2 h 30 min');
      expect(formatDuration(240), '~4 h');
    });
  });

  group('initialsOf', () {
    test('takes the first letters of first and last name', () {
      expect(initialsOf('Amir', 'Softić'), 'AS');
      expect(initialsOf('amir', ''), 'A');
      expect(initialsOf('', ''), '?');
    });
  });

  group('formatInteger', () {
    test('uses a dot as the thousands separator', () {
      expect(formatInteger(0), '0');
      expect(formatInteger(950), '950');
      expect(formatInteger(1968), '1.968');
      expect(formatInteger(187450), '187.450');
      expect(formatInteger(1234567), '1.234.567');
      expect(formatInteger(-1500), '-1.500');
    });
  });

  group('vehicle formats', () {
    test('mileage and displacement carry their unit', () {
      expect(formatMileage(187450), '187.450 km');
      expect(formatMileage(0), '0 km');
      expect(formatDisplacement(1968), '1.968 cm³');
    });

    test('vehicle count uses the Bosnian plural', () {
      expect(formatVehicleCount(1), '1 vozilo');
      expect(formatVehicleCount(2), '2 vozila');
      expect(formatVehicleCount(5), '5 vozila');
      expect(formatVehicleCount(21), '21 vozilo');
    });
  });

  group('formatDate', () {
    test('is day.month.year. with leading zeros', () {
      expect(formatDate(DateTime(2026, 1, 5)), '05.01.2026.');
      expect(formatDate(DateTime(2026, 10, 29)), '29.10.2026.');
    });
  });
}