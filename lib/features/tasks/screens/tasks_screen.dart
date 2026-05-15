import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_top_bar.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/widgets/soft_gate_sheet.dart';
import '../../../shared/widgets/app_toast.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'GÖREVLER'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Görev Listesi', style: AppTextStyles.pageTitle),
            const SizedBox(height: 8),
            Text('Faz 5\'te aktif olacak', style: AppTextStyles.caption),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final auth = context.read<AuthProvider>();
                if (!auth.isLoggedIn) {
                  SoftGateSheet.show(context);
                } else {
                  // Faz 5'te görev eklenecek
                  AppToast.show(context, 'Görev eklendi (Faz 5)', type: AppToastType.success);
                }
              },
              child: const Text('Test Görev Kabul Et', style: TextStyle(color: Colors.white, fontFamily: 'Bebas Neue', fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
