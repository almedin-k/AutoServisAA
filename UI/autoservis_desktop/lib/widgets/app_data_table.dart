import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// One column of [AppDataTable]. [flex] controls how the width is shared between columns.
class AppColumn<T> {
  const AppColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final Widget Function(T item) cell;
  final int flex;

  // Fixed width. When set, [flex] is ignored.
  final double? width;
  final Alignment alignment;
}

// Full-width table.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.items,
    this.onRowTap,
  });

  final List<AppColumn<T>> columns;
  final List<T> items;
  final void Function(T item)? onRowTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) => _buildRow(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (final column in columns)
            _sized(
              column,
              Align(
                alignment: column.alignment,
                child: Text(
                  column.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(T item) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (final column in columns)
            _sized(column, Align(alignment: column.alignment, child: column.cell(item))),
        ],
      ),
    );

    if (onRowTap == null) {
      return row;
    }
    return InkWell(onTap: () => onRowTap!(item), child: row);
  }

  Widget _sized(AppColumn<T> column, Widget child) {
    final padded = Padding(padding: const EdgeInsets.only(right: 12), child: child);
    if (column.width != null) {
      return SizedBox(width: column.width, child: padded);
    }
    return Expanded(flex: column.flex, child: padded);
  }
}