import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../providers/service_provider.dart';
import '../theme/app_theme.dart';
import '../utils/category_icons.dart';

/// The picture of a service. Without a picture (or when it cant be loaded) a placeholder with category icon is shown
class ServiceImage extends StatelessWidget {
  const ServiceImage({super.key, required this.service, this.iconSize = 32});
  final Service service;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(icon: categoryIcon(service.categoryName), iconSize: iconSize);
    if (!service.hasImage) {
      return placeholder;
    }
    final version = service.updatedAt?.millisecondsSinceEpoch ?? 0;
    final url = context.read<ServiceProvider>().imageUrl(service.id, version: version);
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.iconSize});
  final IconData icon;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.header, AppColors.nav],
        ),
      ),
      child: Icon(icon, size: iconSize, color: AppColors.tealLight),
    );
  }
}