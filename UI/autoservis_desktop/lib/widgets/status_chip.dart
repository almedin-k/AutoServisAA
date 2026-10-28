import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Small label for activity Active (green) or Inactive (grey).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});
  final String label;
  final Color color;
  factory StatusChip.active(bool isActive) => StatusChip(
        label: isActive ? 'Aktivno' : 'Neaktivno',
        color: isActive ? AppColors.success : AppColors.textMuted,
      );
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}