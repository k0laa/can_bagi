import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/task_model.dart';
import 'direction_indicator.dart';

String _priorityLabel(int score) {
  if (score >= 8) return 'YÜKSEK';
  if (score >= 5) return 'ORTA';
  return 'DÜŞÜK';
}

class TaskDetailSheet extends StatelessWidget {
  final TaskModel task;
  final double? userLat;
  final double? userLon;
  final bool isTaskActive;
  final bool hasAnyActiveTask;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.userLat,
    required this.userLon,
    required this.isTaskActive,
    required this.hasAnyActiveTask,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
  });

  static Future<void> show({
    required BuildContext context,
    required TaskModel task,
    required double? userLat,
    required double? userLon,
    required bool isTaskActive,
    required bool hasAnyActiveTask,
    required VoidCallback onAccept,
    required VoidCallback onReject,
    required VoidCallback onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TaskDetailSheet(
        task: task,
        userLat: userLat,
        userLon: userLon,
        isTaskActive: isTaskActive,
        hasAnyActiveTask: hasAnyActiveTask,
        onAccept: () {
          Navigator.of(context).pop();
          onAccept();
        },
        onReject: () {
          Navigator.of(context).pop();
          onReject();
        },
        onComplete: () {
          Navigator.of(context).pop();
          onComplete();
        },
      ),
    );
  }

  String _getEmojiForType(String type) {
    switch (type) {
      case 'FOOD_DISTRIBUTION':
        return '📦';
      case 'WATER_CARRY':
        return '💧';
      case 'CLEANING':
        return '🧹';
      case 'CARE':
        return '👴';
      case 'GUIDANCE':
        return '📢';
      case 'RESCUE':
        return '🚨';
      default:
        return '🍳';
    }
  }

  Color _getPriorityColor(int score) {
    if (score >= 8) return AppColors.danger;
    if (score >= 5) return AppColors.warning;
    return const Color(0xFFEAB308);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Text(
                        _getEmojiForType(task.type),
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 28,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.assemblyPoint.name,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: DirectionIndicator(
                        userLat: userLat,
                        userLon: userLon,
                        targetLat: task.assemblyPoint.lat,
                        targetLon: task.assemblyPoint.lon,
                        isLarge: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (task.priorityScore > 0)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priorityScore)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getPriorityColor(task.priorityScore),
                            ),
                          ),
                          child: Text(
                            '⚡ ÖNCELİK: ${_priorityLabel(task.priorityScore)} (${task.priorityScore})',
                            style: TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 14,
                              color: _getPriorityColor(task.priorityScore),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _DetailRow(
                        icon: Icons.access_time,
                        text: '${task.startTime} - ${task.endTime}'),
                    const SizedBox(height: 12),
                    _DetailRow(
                        icon: Icons.people,
                        text:
                            '${task.maxAssignees - task.currentAssignees} / ${task.maxAssignees} kişi gerekiyor',
                        color: AppColors.warning),
                    const SizedBox(height: 24),
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (isTaskActive) ...[
                const Center(
                  child: Text(
                    '✓ Bu görevi kabul ettiniz',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'TAMAMLANDI',
                  onPressed: onComplete,
                  variant: AppButtonVariant.success,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'KABUL ET',
                        onPressed: hasAnyActiveTask ? null : onAccept,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'REDDET',
                        onPressed: onReject,
                        variant: AppButtonVariant.danger,
                      ),
                    ),
                  ],
                ),
                if (hasAnyActiveTask)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(
                      child: Text(
                        'Başka bir aktif göreviniz var.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
              ]
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _DetailRow({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
