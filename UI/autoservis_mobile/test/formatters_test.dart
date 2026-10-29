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
}
