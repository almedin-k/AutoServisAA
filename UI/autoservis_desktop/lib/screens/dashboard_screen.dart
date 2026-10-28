import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/part_provider.dart';
import '../providers/service_category_provider.dart';
import '../providers/service_provider.dart';
import '../theme/app_theme.dart';
import 'service_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _activeServices;
  int? _categories;
  int? _parts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Every number is loaded on its own, so one failing request does not hide the others.
  Future<void> _load() async {
    final services = context.read<ServiceProvider>();
    final categories = context.read<ServiceCategoryProvider>();
    final parts = context.read<PartProvider>();
    final isStaff = context.read<AuthProvider>().isStaff;

    final results = await Future.wait<int?>([
      _count(() async => (await services.get(filter: {'pageSize': 1, 'isActive': true})).totalCount),
      _count(() async => (await categories.get(filter: {'pageSize': 1})).totalCount),
      if (isStaff) _count(() async => (await parts.get(filter: {'pageSize': 1})).totalCount),
    ]);

    if (!mounted) return;
    setState(() {
      _activeServices = results[0];
      _categories = results[1];
      _parts = isStaff ? results[2] : null;
      _isLoading = false;
    });
  }

  Future<int?> _count(Future<int> Function() request) async {
    try {
      return await request();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MasterScreen(
      title: 'Kontrolna tabla',
      section: AppSection.dashboard,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dobro došli, ${auth.user?.firstName ?? ''}.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _KpiCard(label: 'Aktivne usluge', value: _activeServices, isLoading: _isLoading),
                _KpiCard(label: 'Kategorije usluga', value: _categories, isLoading: _isLoading),
                if (auth.isStaff) _KpiCard(label: 'Dijelovi u katalogu', value: _parts, isLoading: _isLoading),
              ],
            ),
            if (auth.isStaff) ...[
              const SizedBox(height: 28),
              Text('Brze akcije', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: AppTheme.accentButton(),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ServiceManagementScreen()),
                ),
                icon: const Icon(Icons.build_outlined),
                label: const Text('Upravljaj uslugama'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, required this.isLoading});

  final String label;
  final int? value;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 10),
              if (isLoading)
                const SizedBox(height: 32, width: 32, child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text(
                  value?.toString() ?? '-',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
