import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Edit and delete icons shown at the end of every table row.
class RowActions extends StatelessWidget {
  const RowActions({super.key, required this.onEdit, required this.onDelete, this.editTooltip = 'Uredi', this.deleteTooltip = 'Obriši'});
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String editTooltip;
  final String deleteTooltip;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: editTooltip,
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, color: AppColors.teal),
        ),
        IconButton(
          tooltip: deleteTooltip,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
        ),
      ],
    );
  }
}