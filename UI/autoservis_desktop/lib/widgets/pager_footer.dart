import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Paging.
class PagerFooter extends StatelessWidget {
  const PagerFooter({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final void Function(int page) onPageChanged;
  int get _totalPages => totalCount == 0 ? 1 : (totalCount + pageSize - 1) ~/ pageSize;
  @override
  Widget build(BuildContext context) {
    final from = totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
    final to = (page * pageSize) > totalCount ? totalCount : page * pageSize;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text(
            'Prikazano $from-$to od $totalCount',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const Spacer(),
          IconButton(
            tooltip: page > 1 ? 'Prethodna stranica' : 'Nalazite se na prvoj stranici',
            onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Stranica $page od $_totalPages'),
          IconButton(
            tooltip: page < _totalPages ? 'Sljedeća stranica' : 'Nalazite se na posljednjoj stranici',
            onPressed: page < _totalPages ? () => onPageChanged(page + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}