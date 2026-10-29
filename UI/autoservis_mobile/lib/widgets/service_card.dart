import 'package:flutter/material.dart';
import '../models/service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'service_image.dart';

// Row of the service list: picture, name, category, duration and price.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});
  final Service service;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 1.5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(width: 78, height: 78, child: ServiceImage(service: service)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.categoryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          formatDuration(service.durationMinutes),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Text(
                          formatMoney(service.price),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.teal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}