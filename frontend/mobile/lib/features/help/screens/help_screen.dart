import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../auth/widgets/soft_gate_sheet.dart';
import '../widgets/category_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _categories = [
    _Category('RESCUE',     '🚨', 'KURTARMA'),
    _Category('MEDICAL',    '🏥', 'TIBBİ'),
    _Category('FOOD',       '🍞', 'GIDA & SU'),
    _Category('SHELTER',    '🏕️', 'BARINMA'),
    _Category('CLOTHES',    '👕', 'GİYSİ'),
    _Category('VULNERABLE', '👶', 'KIRILGAN'),
  ];

  void _onCategoryTap(BuildContext context, _Category cat) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      SoftGateSheet.show(context);
      return;
    }
    context.push('/help/form', extra: {'category': cat.id, 'title': cat.title});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'YARDIM TALEBİ'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bilgi kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textDisabled, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'İnternet bağlantısı olmadan da talepte bulunabilirsiniz',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Kategori Seç', style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text(
              'İhtiyacınıza uygun kategoriyi seçin.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:   2,
                  mainAxisSpacing:  16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return CategoryCard(
                    emoji: cat.emoji,
                    title: cat.title,
                    onTap: () => _onCategoryTap(context, cat),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String id;
  final String emoji;
  final String title;
  const _Category(this.id, this.emoji, this.title);
}
