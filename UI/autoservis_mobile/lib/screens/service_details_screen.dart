import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/service_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/utils_widgets.dart';
import '../widgets/error_banner.dart';
import '../widgets/info_chip.dart';
import '../widgets/service_image.dart';

/// Detailed view of a service: picture, description, duration, price, warranty and the parts that are usually needed.
class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, required this.service});
  final Service service;
  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late Service _service;
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<ServiceProvider>();
    try {
      final full = await provider.getById(_service.id);
      if (!mounted) return;
      setState(() {
        _service = full;
        _isLoading = false;
        _error = null;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _load();
  }
  void _reserve() {
    showMessage(context, 'Rezervacija termina bit će dostupna uskoro.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHero(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildInfoRow(),
                      const SizedBox(height: 28),
                      const Text('Potrebni dijelovi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      _buildParts(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 240,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ServiceImage(service: _service, iconSize: 80),
          Positioned(
            top: topInset + 8,
            left: 12,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Nazad',
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _service.categoryName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal),
          ),
        ),
        const SizedBox(height: 10),
        Text(_service.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 10),
        Text(
          _service.description,
          style: const TextStyle(fontSize: 15, height: 1.45, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InfoChip(
              icon: Icons.timer_outlined,
              label: 'Vrijeme',
              value: formatDuration(_service.durationMinutes),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InfoChip(
              icon: Icons.sell_outlined,
              label: 'Cijena rada',
              value: formatMoney(_service.price),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InfoChip(
              icon: Icons.verified_outlined,
              label: 'Garancija',
              value: formatWarranty(_service.warrantyMonths),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParts() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ErrorBanner(message: _error!),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Pokušaj ponovo'),
          ),
        ],
      );
    }

    if (_service.requiredParts.isEmpty) {
      return const Text(
        'Za ovu uslugu nisu predviđeni zamjenski dijelovi.',
        style: TextStyle(color: AppColors.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final part in _service.requiredParts)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.settings_outlined, size: 20, color: AppColors.teal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(part.partName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(
                  '${part.quantity} × ${formatMoney(part.unitPrice)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        const Text(
          'Cijena usluge obuhvata rad. Dijelovi se naplaćuju posebno, prema stvarnoj potrošnji.',
          style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _reserve,
          child: const Text('Rezerviši termin'),
        ),
      ),
    );
  }
}