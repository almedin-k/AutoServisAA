import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum PhotoAction { gallery, camera, remove }

Future<PhotoAction?> showPhotoSourceSheet(BuildContext context, {required bool hasPhoto}) {
  return showModalBottomSheet<PhotoAction>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.teal),
            title: const Text('Odaberi iz galerije'),
            onTap: () => Navigator.pop(context, PhotoAction.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined, color: AppColors.teal),
            title: const Text('Slikaj kamerom'),
            onTap: () => Navigator.pop(context, PhotoAction.camera),
          ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('Ukloni sliku', style: TextStyle(color: AppColors.danger)),
              onTap: () => Navigator.pop(context, PhotoAction.remove),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}