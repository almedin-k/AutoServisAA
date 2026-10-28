import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Compact dropdown used in list toolbars. Its value is controlled by the parent.
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 200,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T value) onChanged;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          items: items,
          onChanged: (selected) {
            if (selected is T) {
              onChanged(selected);
            }
          },
        ),
      ),
    );
  }
}
