import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppLoader extends StatelessWidget {
  final bool   fullScreen;
  final double size;

  const AppLoader({super.key, this.fullScreen = false, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        color: AppColors.accent,
        strokeWidth: 3,
      ),
    );

    if (!fullScreen) return spinner;

    return Container(
      color: AppColors.background.withValues(alpha: 0.85),
      alignment: Alignment.center,
      child: spinner,
    );
  }
}
