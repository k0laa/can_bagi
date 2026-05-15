import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'PROFİLİM'),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) {
            return _LoggedInView(auth: auth);
          }
          return const _GuestView();
        },
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👤', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Hesabınız Yok', style: AppTextStyles.pageTitle),
          const SizedBox(height: 12),
          Text(
            'Kayıt olarak daha fazla özelliğe erişin.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          const _AdvantageItem('Kan grubunuz kurtarma ekibine iletilir'),
          const _AdvantageItem('Kronik ilaçlarınız bildirilir'),
          const _AdvantageItem('Görev alabilirsiniz'),
          const SizedBox(height: 32),
          AppButton(
            label: 'KAYIT OL',
            onPressed: () {},  // Faz 3'te eklenecek
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'GİRİŞ YAP',
            variant: AppButtonVariant.outline,
            onPressed: () {},  // Faz 3'te eklenecek
          ),
        ],
      ),
    );
  }
}

class _AdvantageItem extends StatelessWidget {
  final String text;
  const _AdvantageItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  final AuthProvider auth;
  const _LoggedInView({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${auth.user?.name} ${auth.user?.surname}',
            style: AppTextStyles.pageTitle,
          ),
          const SizedBox(height: 4),
          Text(auth.user?.phone ?? '', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text('Kan Grubu: ${auth.user?.bloodType}', style: AppTextStyles.body),
          const Spacer(),
          AppButton(
            label: 'ÇIKIŞ YAP',
            variant: AppButtonVariant.danger,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.card,
                  title: Text('Çıkış', style: AppTextStyles.cardTitle),
                  content: Text(
                    'Çıkış yapmak istediğinize emin misiniz?',
                    style: AppTextStyles.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('İptal',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Çık',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.danger)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await auth.logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
