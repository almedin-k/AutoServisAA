import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';
import '../models/service_category.dart';
import '../providers/service_category_provider.dart';
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
import 'category_details_screen.dart';

class CategoryListTab extends StatefulWidget {
  const CategoryListTab({super.key});
  @override
  State<CategoryListTab> createState() => _CategoryListTabState();
}

class _CategoryListTabState extends State<CategoryListTab> {
  static const int _pageSize = 10;
  late final ServiceCategoryProvider _provider;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  SearchResult<ServiceCategory>? _result;
  bool _isLoading = true;
  String? _error;
  int _requestCounter = 0;
  int _page = 1;
  bool? _isActive;
  bool get _hasFilters => _searchController.text.isNotEmpty || _isActive != null;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ServiceCategoryProvider>();
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
        'name': _searchController.text.trim(),
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

  Future<void> _openDetails(ServiceCategory? category) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CategoryDetailsScreen(category: category)),
    );

    if (saved == true && mounted) {
      showSuccess(context, 'Kategorija je spremljena.');
      _load();
    }
  }

  Future<void> _delete(ServiceCategory category) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Brisanje kategorije',
      message: 'Jeste li sigurni da želite obrisati kategoriju "${category.name}"?',
      confirmText: 'Obriši',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await _provider.remove(category.id);
      if (!mounted) return;

      if ((_result?.items.length ?? 0) == 1 && _page > 1) {
        _page--;
      }
      showSuccess(context, 'Kategorija je obrisana.');
      _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      alertBox(context, 'Kategorija se ne može obrisati', e.message);
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
                    hint: 'Pretraži kategorije...',
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
                  label: const Text('Dodaj novu kategoriju'),
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

    final items = _result?.items ?? const <ServiceCategory>[];
    if (items.isEmpty) {
      return EmptyView(message: _hasFilters ? 'Nijedna kategorija ne odgovara filterima.' : 'Još nema kategorija.');
    }

    return Stack(
      children: [
        AppDataTable<ServiceCategory>(
          items: items,
          onRowTap: _openDetails,
          columns: [
            AppColumn<ServiceCategory>(
              label: 'Naziv',
              flex: 3,
              cell: (category) => Text(category.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            AppColumn<ServiceCategory>(
              label: 'Opis',
              flex: 5,
              cell: (category) => Text(
                category.description ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            AppColumn<ServiceCategory>(
              label: 'Status',
              width: 100,
              cell: (category) => StatusChip.active(category.isActive),
            ),
            AppColumn<ServiceCategory>(
              label: 'Akcije',
              width: 110,
              cell: (category) => RowActions(
                editTooltip: 'Uredi kategoriju',
                deleteTooltip: 'Obriši kategoriju',
                onEdit: () => _openDetails(category),
                onDelete: () => _delete(category),
              ),
            ),
          ],
        ),
        if (_isLoading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }
}
