import 'package:flutter/material.dart';

// A category the app does not know gets a general workshop icon.
IconData categoryIcon(String categoryName) {
  final name = categoryName.toLowerCase();
  if (name.contains('ecu') || name.contains('tuning')) {
    return Icons.memory;
  }
  if (name.contains('kočion') || name.contains('kocion')) {
    return Icons.album_outlined;
  }
  if (name.contains('dijagnost')) {
    return Icons.computer_outlined;
  }
  if (name.contains('klima')) {
    return Icons.ac_unit;
  }
  if (name.contains('motor') || name.contains('pogon')) {
    return Icons.settings_outlined;
  }
  if (name.contains('održavanje') || name.contains('odrzavanje')) {
    return Icons.build_outlined;
  }
  return Icons.car_repair;
}