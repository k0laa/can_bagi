import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/task_model.dart';
import '../../../shared/widgets/app_button.dart';

class ActiveTaskBanner extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const ActiveTaskBanner({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'AKTİF GÖREVİNİZ VAR',
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 18,
                  color: AppColors.accent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${task.title} - ${task.assemblyPoint.name}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'GÖREVE GİT',
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
