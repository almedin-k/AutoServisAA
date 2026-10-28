import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/search_result.dart';
import '../models/service.dart';
import '../models/service_category.dart';
import '../providers/service_category_provider.dart';
import '../providers/service_provider.dart';
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
import 'service_details_screen.dart';

class ServiceListTab extends StatefulWidget {
  const ServiceListTab({super.key});
  @override
  State<ServiceListTab> createState() => _ServiceListTabState();
}

class _ServiceListTabState extends State<ServiceListTab> {
  static const int _pageSize = 10;
  late final ServiceProvider _serviceProvider;
  late final ServiceCategoryProvider _categoryProvider;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  SearchResult<Service>? _result;
  List<ServiceCategory> _categories = [];
  bool _isLoading = true;
  String? _error;
  int _requestCounter = 0;
  int _page = 1;
  int? _categoryId;
  bool? _isActive;
  String _sortBy = 'Name';
  bool get _hasFilters => _searchController.text.isNotEmpty || _categoryId != null || _isActive != null;

  @override
  void initState() {
    super.initState();
    _serviceProvider = context.read<ServiceProvider>();
    _categoryProvider = context.read<ServiceCategoryProvider>();
    _loadCategories();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryProvider.get(filter: {'pageSize': 100});
      if (!mounted) return;
      setState(() => _categories = result.items);
    } on ApiClientException {
    }
  }

  Future<void> _load() async {
    final requestId = ++_requestCounter;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _serviceProvider.get(filter: {
        'name': _searchController.text.trim(),
        'categoryId': _categoryId,
        'isActive': _isActive,
        'sortBy': _sortBy,
        'page': _page,
        'pageSize': _pageSize,
      });

      // A newer request was started while this one was running, so this answer is outdated.
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

  void _applyFilter(VoidCallback change) {
    setState(() {
      change();
      _page = 1;
    });
    _load();
  }

  void _clearFilters() {
    _searchController.clear();
    _applyFilter(() {
      _categoryId = null;
      _isActive = null;
    });
  }

  Future<void> _openDetails(int? serviceId) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: serviceId)),
    );

    if (saved == true && mounted) {
      showSuccess(context, 'Usluga je spremljena.');
      _load();
    }
  }

  Future<void> _delete(Service service) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Brisanje usluge',
      message: 'Jeste li sigurni da želite obrisati uslugu "${service.name}"? Ova radnja se ne može poništiti.',
      confirmText: 'Obriši',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await _serviceProvider.remove(service.id);
      if (!mounted) return;

      // Deleting the last row of a page moves back to the previous page.
      if ((_result?.items.length ?? 0) == 1 && _page > 1) {
        _page--;
      }
      showSuccess(context, 'Usluga je obrisana.');
      _load();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      alertBox(context, 'Usluga se ne može obrisati', e.message);
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
            _buildToolbar(),
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

  Widget _buildToolbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SearchBox(
                controller: _searchController,
                hint: 'Pretraži usluge...',
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              style: AppTheme.accentButton(),
              onPressed: () => _openDetails(null),
              icon: const Icon(Icons.add),
              label: const Text('Dodaj novu uslugu'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterDropdown<int?>(
              value: _categoryId,
              width: 230,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Sve kategorije')),
                for (final category in _categories)
                  DropdownMenuItem<int?>(value: category.id, child: Text(category.name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (value) => _applyFilter(() => _categoryId = value),
            ),
            FilterDropdown<bool?>(
              value: _isActive,
              width: 160,
              items: const [
                DropdownMenuItem<bool?>(value: null, child: Text('Svi statusi')),
                DropdownMenuItem<bool?>(value: true, child: Text('Aktivno')),
                DropdownMenuItem<bool?>(value: false, child: Text('Neaktivno')),
              ],
              onChanged: (value) => _applyFilter(() => _isActive = value),
            ),
            FilterDropdown<String>(
              value: _sortBy,
              width: 210,
              items: const [
                DropdownMenuItem(value: 'Name', child: Text('Sortiranje: naziv (A-Ž)')),
                DropdownMenuItem(value: 'PriceAscending', child: Text('Sortiranje: cijena, od najniže')),
                DropdownMenuItem(value: 'PriceDescending', child: Text('Sortiranje: cijena, od najviše')),
                DropdownMenuItem(value: 'ShortestFirst', child: Text('Sortiranje: najkraće prvo')),
                DropdownMenuItem(value: 'Newest', child: Text('Sortiranje: najnovije prvo')),
              ],
              onChanged: (value) => _applyFilter(() => _sortBy = value),
            ),
            if (_hasFilters)
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Poništi filtere'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading && _result == null) {
      return const LoadingView();
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    final items = _result?.items ?? const <Service>[];
    if (items.isEmpty) {
      return EmptyView(message: _hasFilters ? 'Nijedna usluga ne odgovara filterima.' : 'Još nema usluga.');
    }

    return Stack(
      children: [
        AppDataTable<Service>(
          items: items,
          onRowTap: (service) => _openDetails(service.id),
          columns: [
            AppColumn<Service>(label: 'Naziv', flex: 3, cell: _buildNameCell),
            AppColumn<Service>(
              label: 'Kategorija',
              flex: 2,
              cell: (service) => Text(service.categoryName, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            AppColumn<Service>(
              label: 'Opis',
              flex: 4,
              cell: (service) => Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            AppColumn<Service>(
              label: 'Vrijeme (min)',
              width: 100,
              cell: (service) => Text(service.durationMinutes.toString()),
            ),
            AppColumn<Service>(
              label: 'Cijena (KM)',
              width: 100,
              cell: (service) => Text(
                formatDecimal(service.price),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            AppColumn<Service>(
              label: 'Status',
              width: 100,
              cell: (service) => StatusChip.active(service.isActive),
            ),
            AppColumn<Service>(
              label: 'Akcije',
              width: 110,
              cell: (service) => RowActions(
                editTooltip: 'Uredi uslugu',
                deleteTooltip: 'Obriši uslugu',
                onEdit: () => _openDetails(service.id),
                onDelete: () => _delete(service),
              ),
            ),
          ],
        ),
        if (_isLoading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
      ],
    );
  }

  Widget _buildNameCell(Service service) {
    final version = service.updatedAt?.millisecondsSinceEpoch ?? 0;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 40,
            height: 40,
            child: service.hasImage
                ? Image.network(
                    _serviceProvider.imageUrl(service.id, version: version),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            service.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
        color: AppColors.field,
        child: const Icon(Icons.build_outlined, size: 20, color: AppColors.textMuted),
      );
}
