// Small reusable form validators. Every validator returns null when the value is valid, otherwise the message shown under the control.
typedef FieldValidator = String? Function(String?);
class Validators {
  Validators._();
  static const String requiredMessage = 'Ovo polje je obavezno.';
  static FieldValidator required([String message = requiredMessage]) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }
  static FieldValidator maxLength(int max, [String? message]) {
    return (value) {
      if (value != null && value.trim().length > max) {
        return message ?? 'Ne može imati više od $max znakova.';
      }
      return null;
    };
  }

  // A decimal number with an optional comma or dot, for example "12,50".
  static FieldValidator decimal({
    required double min,
    required double max,
    bool minInclusive = true,
    int maxDecimals = 2,
  }) {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return requiredMessage;
      }

      final number = parseDecimal(text);
      if (number == null) {
        return 'Unesite broj, na primjer 25,50.';
      }

      final tooSmall = minInclusive ? number < min : number <= min;
      if (tooSmall) {
        return minInclusive
            ? 'Vrijednost ne može biti manja od ${_plain(min)}.'
            : 'Vrijednost mora biti veća od ${_plain(min)}.';
      }
      if (number > max) {
        return 'Vrijednost ne može biti veća od ${_plain(max)}.';
      }

      final normalized = text.replaceAll(',', '.');
      final dot = normalized.indexOf('.');
      if (dot >= 0 && normalized.length - dot - 1 > maxDecimals) {
        return 'Dozvoljeni broj decimalnih mjesta je: $maxDecimals.';
      }
      return null;
    };
  }

  static FieldValidator integer({
    required int min,
    required int max,
    int? multipleOf,
  }) {
    return (value) {
      final text = (value ?? '').trim();
      if (text.isEmpty) {
        return requiredMessage;
      }

      final number = int.tryParse(text);
      if (number == null) {
        return 'Unesite cijeli broj.';
      }
      if (number < min || number > max) {
        return 'Vrijednost mora biti između $min i $max.';
      }
      if (multipleOf != null && number % multipleOf != 0) {
        return 'Vrijednost mora biti djelioc broja $multipleOf.';
      }
      return null;
    };
  }

  // Runs the validators in order and returns the first message.
  static FieldValidator compose(List<FieldValidator> validators) {
    return (value) {
      for (final validator in validators) {
        final message = validator(value);
        if (message != null) {
          return message;
        }
      }
      return null;
    };
  }

  static double? parseDecimal(String text) => double.tryParse(text.trim().replaceAll(',', '.'));
  static String _plain(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString().replaceAll('.', ',');
}
