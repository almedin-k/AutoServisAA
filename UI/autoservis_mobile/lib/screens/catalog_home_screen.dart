import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_category.dart';
import '../providers/catalog_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_tile.dart';
import '../widgets/dark_header.dart';
import '../widgets/state_views.dart';
import 'service_list_screen.dart';

/// Home tab: Tapping on a tile opens the service list for that category, a submitted search opens the list with that text.
class CatalogHomeScreen extends StatefulWidget {
  const CatalogHomeScreen({super.key});
  @override
  State<CatalogHomeScreen> createState() => _CatalogHomeScreenState();
}

class _CatalogHomeScreenState extends State<CatalogHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Prices can change at any time, so the catalog is refreshed every time the home screen is created.
    Future.microtask(() {
      if (mounted) {
        context.read<CatalogProvider>().load(force: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openList({ServiceCategory? category, String? query}) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceListScreen(
          categoryId: category?.id,
          title: category?.name,
          initialQuery: query,
        ),
      ),
    );

    if (mounted) {
      _searchController.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.teal,
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () => context.read<CatalogProvider>().load(force: true),
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DarkHeader(
              title: 'Usluge',
              overlap: 40,
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  final text = value.trim();
                  if (text.isNotEmpty) {
                    _openList(query: text);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Pretraži usluge...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            _buildContent(catalog),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CatalogProvider catalog) {
    final stateHeight = MediaQuery.sizeOf(context).height * 0.4;
    if (!catalog.isLoaded && catalog.isLoading) {
      return SizedBox(height: stateHeight, child: const LoadingView());
    }
    if (!catalog.isLoaded && catalog.error != null) {
      return SizedBox(
        height: stateHeight,
        child: ErrorView(
          message: catalog.error!,
          onRetry: () => context.read<CatalogProvider>().load(force: true),
        ),
      );
    }
    final categories = catalog.categories;
    if (categories.isEmpty) {
      return SizedBox(
        height: stateHeight,
        child: const EmptyView(
          icon: Icons.build_outlined,
          message: 'Trenutno nema dostupnih usluga',
          hint: 'Pokušajte ponovo malo kasnije.',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          for (var i = 0; i < categories.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: i + 2 < categories.length ? 14 : 0),
              child: _buildRow(catalog, categories, i),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(CatalogProvider catalog, List<ServiceCategory> categories, int start) {
    Widget tile(ServiceCategory category) {
      return CategoryTile(
        category: category,
        minPrice: catalog.minPriceFor(category.id),
        onTap: () => _openList(category: category),
      );
    }
    final hasSecond = start + 1 < categories.length;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tile(categories[start])),
          const SizedBox(width: 14),
          Expanded(child: hasSecond ? tile(categories[start + 1]) : const SizedBox.shrink()),
        ],
      ),
    );
  }
}