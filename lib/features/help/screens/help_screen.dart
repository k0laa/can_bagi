import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../auth/widgets/soft_gate_sheet.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _categories = [
    _Category('🏥', 'Tıbbi Yardım',   'Yaralı, hasta, ilaç ihtiyacı'),
    _Category('🍞', 'Gıda & Su',      'Yiyecek, içecek ihtiyacı'),
    _Category('🏠', 'Barınak',        'Konut, sığınak ihtiyacı'),
    _Category('👶', 'Çocuk & Bebek',  'Bebek bezi, mama, güvenlik'),
    _Category('♿', 'Engelli Desteği','Hareket kısıtlılığı, özel ihtiyaç'),
    _Category('🔧', 'Teknik Destek',  'Enkaz, kurtarma, araç'),
  ];

  void _onCategoryTap(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      SoftGateSheet.show(context);
      return;
    }
    // Faz 4'te form sayfasına git
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
                  mainAxisSpacing:  12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return AppCard(
                    onTap: () => _onCategoryTap(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.emoji,
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(cat.title,
                            style: AppTextStyles.label,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        Text(cat.subtitle,
                            style: AppTextStyles.small,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
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
  final String emoji;
  final String title;
  final String subtitle;
  const _Category(this.emoji, this.title, this.subtitle);
}
