import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  /// Global toast gösterici — ScaffoldMessenger üzerinden
  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _colorFor(type);
    final icon  = _iconFor(type);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorFor(AppToastType type) {
    switch (type) {
      case AppToastType.success: return AppColors.success;
      case AppToastType.error:   return AppColors.danger;
      case AppToastType.warning: return AppColors.warning;
      case AppToastType.info:    return AppColors.info;
    }
  }

  static IconData _iconFor(AppToastType type) {
    switch (type) {
      case AppToastType.success: return Icons.check_circle_outline;
      case AppToastType.error:   return Icons.error_outline;
      case AppToastType.warning: return Icons.warning_amber_outlined;
      case AppToastType.info:    return Icons.info_outline;
    }
  }
}
