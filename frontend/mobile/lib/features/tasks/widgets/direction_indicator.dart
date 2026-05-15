import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../utils/location_utils.dart';

class DirectionIndicator extends StatelessWidget {
  final double? userLat;
  final double? userLon;
  final double targetLat;
  final double targetLon;
  final bool isLarge;

  const DirectionIndicator({
    super.key,
    required this.userLat,
    required this.userLon,
    required this.targetLat,
    required this.targetLon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (userLat == null || userLon == null) {
      return Text(
        'Konum bekleniyor...',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: isLarge ? 16 : 14,
          color: AppColors.textDisabled,
        ),
      );
    }

    final distanceMeters = LocationUtils.calculateDistance(userLat!, userLon!, targetLat, targetLon);
    final directionStr = LocationUtils.calculateDirection(userLat!, userLon!, targetLat, targetLon);

    String distanceText;
    if (distanceMeters < 1000) {
      distanceText = '${distanceMeters.toStringAsFixed(0)} m';
    } else {
      distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }

    return Text(
      '$directionStr • $distanceText',
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: isLarge ? 16 : 14,
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
