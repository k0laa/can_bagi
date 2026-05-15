import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_top_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'YARDIM TALEBİ'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🆘', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Yardım Kategorileri', style: AppTextStyles.pageTitle),
            const SizedBox(height: 8),
            Text('Faz 4\'te aktif olacak', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
