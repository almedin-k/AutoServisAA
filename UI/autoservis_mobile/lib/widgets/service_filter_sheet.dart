import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

// Orders sorting/filtering
enum ServiceSort {
  byName('Name', 'Naziv'),
  priceAscending('PriceAscending', 'Cijena: od najniže'),
  priceDescending('PriceDescending', 'Cijena: od najviše'),
  shortestFirst('ShortestFirst', 'Najkraće trajanje'),
  newest('Newest', 'Najnovije');
  const ServiceSort(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

// The filters of the service list that are chosen in the bottom sheet.
class ServiceFilter {
  const ServiceFilter({this.minPrice, this.maxPrice, this.sort = ServiceSort.byName});

  final double? minPrice;
  final double? maxPrice;
  final ServiceSort sort;
  bool get isActive => minPrice != null || maxPrice != null || sort != ServiceSort.byName;
}

Future<ServiceFilter?> showServiceFilterSheet(
  BuildContext context, {
  required ServiceFilter current,
  required ({double min, double max})? bounds,
}) {
  return showModalBottomSheet<ServiceFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _FilterSheet(current: current, bounds: bounds),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.current, required this.bounds});
  final ServiceFilter current;
  final ({double min, double max})? bounds;
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late RangeValues _range;
  late ServiceSort _sort;
  @override
  void initState() {
    super.initState();
    _sort = widget.current.sort;
    final bounds = widget.bounds;
    if (bounds == null) {
      _range = const RangeValues(0, 1);
    } else {
      _range = RangeValues(
        _within(widget.current.minPrice ?? bounds.min, bounds.min, bounds.max),
        _within(widget.current.maxPrice ?? bounds.max, bounds.min, bounds.max),
      );
    }
  }

  static double _within(double value, double lowest, double highest) {
    if (value < lowest) return lowest;
    if (value > highest) return highest;
    return value;
  }

  int _divisions(({double min, double max}) bounds) {
    final span = (bounds.max - bounds.min).round();
    if (span < 1) return 1;
    return span > 500 ? 500 : span;
  }

  void _apply() {
    final bounds = widget.bounds;
    // For optimization, only send min/max if they are different from the bounds
    final minPrice = bounds != null && _range.start > bounds.min ? _range.start.roundToDouble() : null;
    final maxPrice = bounds != null && _range.end < bounds.max ? _range.end.roundToDouble() : null;
    Navigator.of(context).pop(ServiceFilter(minPrice: minPrice, maxPrice: maxPrice, sort: _sort));
  }

  void _reset() {
    Navigator.of(context).pop(const ServiceFilter());
  }
  @override
  Widget build(BuildContext context) {
    final bounds = widget.bounds;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filteri', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            if (bounds != null) ...[
              const SizedBox(height: 20),
              const Text('Raspon cijene', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                '${formatMoney(_range.start.roundToDouble())} - ${formatMoney(_range.end.roundToDouble())}',
                style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w700),
              ),
              RangeSlider(
                values: _range,
                min: bounds.min,
                max: bounds.max,
                divisions: _divisions(bounds),
                activeColor: AppColors.teal,
                labels: RangeLabels(
                  formatMoney(_range.start.roundToDouble()),
                  formatMoney(_range.end.roundToDouble()),
                ),
                onChanged: (values) => setState(() => _range = values),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Sortiraj po', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            for (final option in ServiceSort.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(option.label),
                trailing: option == _sort ? const Icon(Icons.check, color: AppColors.teal) : null,
                onTap: () => setState(() => _sort = option),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: _reset, child: const Text('Poništi')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(onPressed: _apply, child: const Text('Primijeni filtere')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}