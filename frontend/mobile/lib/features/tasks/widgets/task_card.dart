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
      case 'RESCUE': return '🚨';
      default: return '🍳';
    }
  }

  Color _getPriorityColor(int score) {
    if (score >= 8) return AppColors.danger;
    if (score >= 5) return AppColors.warning;
    return const Color(0xFFEAB308); // sarı
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priorityScore);
    final spotsLeft = task.maxAssignees - task.currentAssignees;

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontFamily: 'Bebas Neue',
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (task.priorityScore > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: priorityColor, width: 1),
                        ),
                        child: Text(
                          '${task.priorityScore}',
                          style: TextStyle(
                            fontFamily: 'Bebas Neue',
                            fontSize: 13,
                            color: priorityColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                DirectionIndicator(
                  userLat: userLat,
                  userLon: userLon,
                  targetLat: task.assemblyPoint.lat,
                  targetLon: task.assemblyPoint.lon,
                ),
                if (task.maxAssignees > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$spotsLeft / ${task.maxAssignees} yer boş',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.textDisabled,
                      ),
                    ),
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
