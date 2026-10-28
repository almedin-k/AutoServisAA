import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Shared message used by validators.
const String mField = 'Ovo polje je obavezno.';

void alertBox(BuildContext context, String title, String content) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('U redu'),
        ),
      ],
    ),
  );
}

// Asks the user to confirm an action. Returns true only when the confirm button was pressed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Da',
  String cancelText = 'Odustani',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: destructive
              ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        width: 420,
      ),
    );
}

/// Currency format: decimal comma, for example 25,50 KM.
String formatDecimal(double value) => value.toStringAsFixed(2).replaceAll('.', ',');
String formatMoney(double value) => '${formatDecimal(value)} KM';