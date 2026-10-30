String formatDecimal(double value) {
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final integer = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < integer.length; i++) {
    if (i > 0 && (integer.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(integer[i]);
  }
  final sign = value < 0 ? '-' : '';
  return '$sign$buffer,${parts[1]}';
}
String formatMoney(double value) => '${formatDecimal(value)} KM';

String pluralBs(int count, String one, String few, String many) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) {
    return one;
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return few;
  }
  return many;
}

String formatDuration(int minutes) {
  if (minutes < 60) {
    return '~$minutes min';
  }
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '~$hours h' : '~$hours h $rest min';
}

String formatWarranty(int months) {
  if (months <= 0) {
    return 'Bez garancije';
  }
  return '$months ${pluralBs(months, 'mjesec', 'mjeseca', 'mjeseci')}';
}

String initialsOf(String firstName, String lastName) {
  final first = firstName.trim();
  final last = lastName.trim();
  final text = '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}';
  return text.isEmpty ? '?' : text.toUpperCase();
}

String formatInteger(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

String formatMileage(int kilometres) => '${formatInteger(kilometres)} km';
String formatDisplacement(int cubicCentimetres) => '${formatInteger(cubicCentimetres)} cm³';
String formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}.';
}
String formatVehicleCount(int count) => '$count ${pluralBs(count, 'vozilo', 'vozila', 'vozila')}';