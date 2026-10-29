import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/catalog_provider.dart';
import '../providers/service_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/utils_widgets.dart';
import '../widgets/dark_header.dart';
import '../widgets/service_card.dart';
import '../widgets/service_filter_sheet.dart';
import '../widgets/state_views.dart';
import 'service_details_screen.dart';

// Service catalog: real-time search, category chips, price range and sorting. Next page is loaded when teh user scrolls to the bottom
class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({
    super.key,
    this.categoryId,
    this.title,
    this.initialQuery,
  });
  final int? categoryId;
  final String? title;
  final String? initialQuery;
  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  static const int _pageSize = 20;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  final List<Service> _items = [];
  int _page = 1;
  int _totalCount = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  // Every request gets a number so a slow response can never overwrite the result of a newer search.
  int _requestId = 0;
  int? _categoryId;
  ServiceFilter _filter = const ServiceFilter();
  @override
  void initState() {
    super.initState();
    _categoryId = widget.categoryId;
    _searchController.text = widget.initialQuery ?? '';
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      if (mounted) {
        context.read<CatalogProvider>().load();
      }
    });
    _fetch();
  }
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _query(int page) => {
        'name': _searchController.text.trim(),
        'categoryId': _categoryId,
        'minPrice': _filter.minPrice,
        'maxPrice': _filter.maxPrice,
        'sortBy': _filter.sort.apiValue,
        'page': page,
        'pageSize': _pageSize,
      };

  void _startLoad() {
    setState(() {
      _items.clear();
      _totalCount = 0;
      _isLoading = true;
      _isLoadingMore = false;
      _error = null;
    });
    _fetch();
  }

  Future<void> _fetch() async {
    final requestId = ++_requestId;
    final provider = context.read<ServiceProvider>();
    try {
      final result = await provider.get(filter: _query(1));
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _page = 1;
        _totalCount = result.totalCount;
        _isLoading = false;
        _isLoadingMore = false;
        _error = null;
      });
    } on ApiClientException catch (e) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
      if (_items.isNotEmpty) {
        showMessage(context, e.message);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || _isLoadingMore || _items.length >= _totalCount) {
      return;
    }
    final requestId = _requestId;
    final provider = context.read<ServiceProvider>();
    setState(() => _isLoadingMore = true);
    try {
      final result = await provider.get(filter: _query(_page + 1));
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _items.addAll(result.items);
        _page += 1;
        _totalCount = result.totalCount;
        _isLoadingMore = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() => _isLoadingMore = false);
      showMessage(context, e.message);
    }
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  void _onSearchChanged(String _) {
    setState(() {}); // shows or hides the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _startLoad);
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() {});
    _startLoad();
  }

  void _selectCategory(int? id) {
    if (_categoryId == id) {
      return;
    }
    _categoryId = id;
    _startLoad();
  }

  Future<void> _openFilters() async {
    final catalog = context.read<CatalogProvider>();
    final result = await showServiceFilterSheet(
      context,
      current: _filter,
      bounds: catalog.priceBounds,
    );
    if (result == null || !mounted) {
      return;
    }
    _filter = result;
    _startLoad();
  }

  void _openDetails(Service service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ServiceDetailsScreen(service: service)),
    );
  }

  String _title(CatalogProvider catalog) {
    if (_categoryId == null) {
      return 'Usluge';
    }

    for (final category in catalog.categories) {
      if (category.id == _categoryId) { return category.name;}
    }
    return widget.title ?? 'Usluge';
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final canGoBack = Navigator.of(context).canPop();
    return Scaffold(
      body: Column(
        children: [
          DarkHeader(
            title: _title(catalog),
            leading: canGoBack? IconButton(
              tooltip: 'Nazad',
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ): null,
            child: Row(
              children: [
                Expanded(child: _buildSearchField()),
                const SizedBox(width: 10),
                _buildFilterButton(),
              ],
            ),
          ),
          _buildCategoryChips(catalog),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchChanged,
      onSubmitted: (_) {
        _debounce?.cancel();
        _startLoad();
      },
      decoration: InputDecoration(
        hintText: 'Pretraži usluge...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Obriši pretragu',
                icon: const Icon(Icons.close),
                onPressed: _clearSearch,
              ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Material(
      color: AppColors.teal,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openFilters,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Center(
            child: Badge(
              backgroundColor: Colors.white,
              smallSize: 9,
              isLabelVisible: _filter.isActive,
              child: const Icon(Icons.tune, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(CatalogProvider catalog) {
    final categories = catalog.categories;
    if (categories.isEmpty) {
      return const SizedBox(height: 8);
    }

    Widget chip(String label, bool selected, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: AppColors.teal,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          chip('Sve', _categoryId == null, () => _selectCategory(null)),
          for (final category in categories)
            chip(category.name, _categoryId == category.id, () => _selectCategory(category.id)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const LoadingView();
    }
    if (_error != null && _items.isEmpty) {
      return ErrorView(message: _error!, onRetry: _startLoad);
    }
    if (_items.isEmpty) {
      return const EmptyView(
        icon: Icons.search_off,
        message: 'Nema pronađenih usluga',
        hint: 'Pokušajte s drugim pojmom ili promijenite filtere.',
      );
    }
    final hasMore = _items.length < _totalCount;

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: _fetch,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: _items.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _buildFooter(hasMore);
          }
          final service = _items[index];
          return ServiceCard(service: service, onTap: () => _openDetails(service));
        },
      ),
    );
  }

  Widget _buildFooter(bool hasMore) {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (hasMore) {
      return Center(
        child: TextButton(onPressed: _loadMore, child: const Text('Učitaj još')),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          '$_totalCount ${pluralBs(_totalCount, 'usluga', 'usluge', 'usluga')}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ),
    );
  }
}