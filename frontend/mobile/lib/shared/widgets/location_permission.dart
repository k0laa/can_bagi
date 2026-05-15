import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/location_provider.dart';

class LocationPermissionWidget extends StatelessWidget {
  const LocationPermissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, loc, _) {
        if (loc.hasPermission) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => _handleTap(context, loc),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_off_outlined,
                    color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Konum izni gerekli — dokunun',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.warning, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTap(
      BuildContext context, LocationProvider loc) async {
    if (loc.status == LocationStatus.permanentlyDenied) {
      await loc.openSettings();
    } else {
      await loc.requestPermission();
    }
  }
}
