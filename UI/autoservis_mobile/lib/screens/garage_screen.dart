import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../utils/api_client_exception.dart';
import '../utils/utils_widgets.dart';
import '../widgets/dark_header.dart';
import '../widgets/state_views.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_form_screen.dart';

// Garage: vehicles of the signed-in client with add, edit and delete.
class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});
  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  @override
  void initState() {
    super.initState();
    // The vehicles could b cganged on another device, so they are refreshed every time the garage opens.
    Future.microtask(() {
      if (mounted) {
        context.read<VehicleProvider>().load(force: true);
      }
    });
  }

  Future<void> _openForm([Vehicle? vehicle]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
    );
    if (saved == true && mounted) {
      showMessage(context, 'Vozilo je sačuvano.');
    }
  }

  Future<void> _delete(Vehicle vehicle) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Brisanje vozila',
      message: 'Da li ste sigurni da želite obrisati vozilo ${vehicle.title} (${vehicle.vin})?',
      confirmText: 'Obriši',
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    try {
      await context.read<VehicleProvider>().remove(vehicle.id);
      if (mounted) {
        showMessage(context, 'Vozilo je obrisano.');
      }
    } on ApiClientException catch (e) {
      if (mounted) {
        showMessage(context, e.message);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();
    return Scaffold(
      body: RefreshIndicator(
        edgeOffset: MediaQuery.paddingOf(context).top,
        onRefresh: () => context.read<VehicleProvider>().load(force: true),
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DarkHeader(
              title: 'Moja garaža',
              leading: IconButton(
                tooltip: 'Nazad',
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            _buildContent(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(VehicleProvider provider) {
    final stateHeight = MediaQuery.sizeOf(context).height * 0.4;
    if (!provider.isLoaded && provider.isLoading) {
      return SizedBox(height: stateHeight, child: const LoadingView());
    }
    if (!provider.isLoaded && provider.error != null) {
      return SizedBox(
        height: stateHeight,
        child: ErrorView(
          message: provider.error!,
          onRetry: () => context.read<VehicleProvider>().load(force: true),
        ),
      );
    }
    final vehicles = provider.vehicles;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            label: const Text('Dodaj vozilo'),
          ),
          const SizedBox(height: 16),
          if (vehicles.isEmpty)
            SizedBox(
              height: stateHeight,
              child: const EmptyView(
                icon: Icons.directions_car_outlined,
                message: 'Garaža je prazna',
                hint: 'Dodajte svoje vozilo da biste mogli jednostavno zakazati termin.',
              ),
            )
          else
            for (var i = 0; i < vehicles.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              VehicleCard(
                vehicle: vehicles[i],
                onEdit: () => _openForm(vehicles[i]),
                onDelete: () => _delete(vehicles[i]),
              ),
            ],
        ],
      ),
    );
  }
}