import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/part.dart';
import '../models/search_result.dart';
import '../providers/part_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/utils_widgets.dart';
import '../widgets/app_data_table.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/pager_footer.dart';
import '../widgets/row_actions.dart';
import '../widgets/search_box.dart';
import '../widgets/state_views.dart';
import '../widgets/status_chip.dart';
import 'part_details_screen.dart';

class PartListTab extends StatefulWidget {
  const PartListTab({super.key});
  @override
  State<PartListTab> createState() => _PartListTabState();
}

class _PartListTabState extends State<PartListTab> {
  static const int _pageSize = 10;
  late final PartProvider _provider;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  SearchResult<Part>? _result;
  bool _isLoading = true;
  String? _error;
  int _requestCounter = 0;
  int _page = 1;
  bool? _isActive;
  bool get _hasFilters => _searchController.text.isNotEmpty || _isActive != null;

  @override
  void initState() {
    super.initState();
    _provider = context.read<PartProvider>();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final requestId = ++_requestCounter;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _provider.get(filter: {
        'text': _searchController.text.trim(),
        'isActive': _isActive,
        'page': _page,
        'pageSize': _pageSize,
      });

      if (!mounted || requestId != _requestCounter) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted || requestId != _requestCounter) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _page = 1;
      _load();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _isActive = null;
      _page = 1;
    });
    _load();
  }

  Future<void> _openDetails(Part? part) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PartDetailsScreen(part: part)),
    );

    if (saved == true && mounted) {
      showSuccess(context, 'Dio je spremljen.');
      _load();
    }
  }

  Future<void> _delete(Part part) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Brisanje dijela',
      message: 'Jeste li sigurni da želite obrisati dio "${part.name}"?',
      confirmText: 'Obriši',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await _provider.remove(part.id);
      if (!mounted) return;

      if ((_result?.items.length ?? 0) == 1 && _page > 1) {
        _page--;
      }
      showSuccess(context, 'Dio je obrisan.');
      _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      alertBox(context, 'Dio se ne može obrisati', e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchBox(
                    controller: _searchController,
                    hint: 'Pretraži po nazivu ili SKU oznaci...',
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                FilterDropdown<bool?>(
                  value: _isActive,
                  width: 160,
                  items: const [
                    DropdownMenuItem<bool?>(value: null, child: Text('Svi statusi')),
                    DropdownMenuItem<bool?>(value: true, child: Text('Aktivno')),
                    DropdownMenuItem<bool?>(value: false, child: Text('Neaktivno')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                      _page = 1;
                    });
                    _load();
                  },
                ),
                if (_hasFilters) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                    label: const Text('Poništi filtere'),
                  ),
                ],
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: AppTheme.accentButton(),
                  onPressed: () => _openDetails(null),
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj novi dio'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
            if (_result != null && _error == null)
              PagerFooter(
                page: _result!.page,
                pageSize: _result!.pageSize,
                totalCount: _result!.totalCount,
                onPageChanged: (page) {
                  setState(() => _page = page);
                  _load();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _result == null) {
      return const LoadingView();
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    final items = _result?.items ?? const <Part>[];
    if (items.isEmpty) {
      return EmptyView(message: _hasFilters ? 'Nijedan dio ne odgovara filterima.' : 'Još nema dijelova.');
    }

    return Stack(
      children: [
        AppDataTable<Part>(
          items: items,
          onRowTap: _openDetails,
          columns: [
            AppColumn<Part>(
              label: 'Naziv',
              flex: 4,
              cell: (part) => Text(part.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            AppColumn<Part>(
              label: 'SKU oznaka',
              flex: 2,
              cell: (part) => Text(part.sku ?? '-', style: const TextStyle(color: AppColors.textMuted)),
            ),
            AppColumn<Part>(
              label: 'Jedinična cijena (KM)',
              width: 140,
              cell: (part) => Text(formatDecimal(part.unitPrice), style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            AppColumn<Part>(
              label: 'Status',
              width: 100,
              cell: (part) => StatusChip.active(part.isActive),
            ),
            AppColumn<Part>(
              label: 'Akcije',
              width: 110,
              cell: (part) => RowActions(
                editTooltip: 'Uredi dio',
                deleteTooltip: 'Obriši dio',
                onEdit: () => _openDetails(part),
                onDelete: () => _delete(part),
              ),
            ),
          ],
        ),
        if (_isLoading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}
