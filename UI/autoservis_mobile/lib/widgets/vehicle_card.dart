import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

enum _VehicleAction { edit, delete }

// A vehicle in garage: brand and model, year and engine, mileage and VIN. Tapping the card opens the edit form, the menu offers edit and delete.
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  String get _engineSummary {
    final power = '${vehicle.enginePowerKw} kW';
    return vehicle.engineDisplacementCc > 0
        ? '${formatDisplacement(vehicle.engineDisplacementCc)} • $power'
        : power;
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1.5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.directions_car_filled_outlined, color: AppColors.teal, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.productionYear}. • ${vehicle.engine.label}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        _spec(Icons.settings_outlined, _engineSummary),
                        _spec(Icons.speed_outlined, formatMileage(vehicle.mileageKm)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'VIN: ${vehicle.vin}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.4),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_VehicleAction>(
                tooltip: 'Opcije',
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                onSelected: (action) {
                  if (action == _VehicleAction.edit) {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: _VehicleAction.edit, child: Text('Uredi')),
                  PopupMenuItem(
                    value: _VehicleAction.delete,
                    child: Text('Obriši', style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _spec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.teal),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}