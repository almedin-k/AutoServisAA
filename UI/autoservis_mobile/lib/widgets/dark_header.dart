import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Header with the company name
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.fontSize = 20});
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'AutoServis', style: TextStyle(color: Colors.white)),
          TextSpan(text: 'AA', style: TextStyle(color: AppColors.tealLight)),
        ],
      ),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
    );
  }
}

class DarkHeader extends StatelessWidget {
  const DarkHeader({
    super.key,
    this.title,
    this.child,
    this.leading,
    this.overlap = 0,
  });
  final String? title;
  final Widget? child;
  final Widget? leading;
  final double overlap;
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: -overlap,
          child: const ColoredBox(color: AppColors.header),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, topInset + 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 48, child: leading),
                  const Expanded(child: Center(child: BrandTitle())),
                  const SizedBox(width: 48),
                ],
              ),
              if (title != null) ...[
                const SizedBox(height: 14),
                Text(
                  title!,
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 14),
                child!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}