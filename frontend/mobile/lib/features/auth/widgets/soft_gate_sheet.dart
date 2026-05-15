import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';

class SoftGateSheet extends StatelessWidget {
  const SoftGateSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context:        context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SoftGateSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text('Bu Özellik İçin Giriş Gerekli',
              style: AppTextStyles.cardTitle),
          const SizedBox(height: 8),
          Text(
            'Kayıt olarak daha fazla özelliğe erişin:',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),

          const _AdvItem(Icons.bloodtype_outlined, 'Kan grubunuz kurtarma ekibine iletilir'),
          const _AdvItem(Icons.medication_outlined, 'Kronik ilaçlarınız bildirilir'),
          const _AdvItem(Icons.task_alt_outlined,   'Görev alabilirsiniz'),
          const _AdvItem(Icons.map_outlined,        'Konumunuz kayıt altına alınır'),

          const SizedBox(height: 24),

          Consumer<AuthProvider>(
            builder: (context, auth, _) => Column(
              children: [
                AppButton(
                  label:     'GİRİŞ YAP',
                  isLoading: auth.isLoading,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/login');
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  label:    'KAYIT OL',
                  variant:  AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/register');
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  label:    'Şimdi Değil',
                  variant:  AppButtonVariant.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvItem extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _AdvItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}
