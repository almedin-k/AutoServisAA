import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Round profile picture. Without a picture the initials of the user are shown
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.imageBytes,
    this.radius = 42,
    this.isBusy = false,
  });
  final String initials;
  final Uint8List? imageBytes;
  final double radius;

  //For showing a progress indicator over the picture while it is being uploaded.
  final bool isBusy;
  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.teal,
          backgroundImage: bytes == null ? null : MemoryImage(bytes),
          child: bytes == null
              ? Text(
                  initials,
                  style: TextStyle(fontSize: radius * 0.72, fontWeight: FontWeight.w800, color: Colors.white),
                )
              : null,
        ),
        if (isBusy)
          Positioned.fill(
            child: ClipOval(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(
                  child: SizedBox(
                    height: radius * 0.6,
                    width: radius * 0.6,
                    child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}