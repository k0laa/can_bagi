import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/task_model.dart';
import 'direction_indicator.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final double? userLat;
  final double? userLon;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.userLat,
    required this.userLon,
    required this.onTap,
  });

  String _getEmojiForType(String type) {
    switch (type) {
      case 'FOOD_DISTRIBUTION': return '📦';
      case 'WATER_CARRY': return '💧';
      case 'CLEANING': return '🧹';
      case 'CARE': return '👴';
      case 'GUIDANCE': return '📢';
      default: return '🍳';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            _getEmojiForType(task.type),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                DirectionIndicator(
                  userLat: userLat,
                  userLon: userLon,
                  targetLat: task.assemblyPoint.lat,
                  targetLon: task.assemblyPoint.lon,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}
