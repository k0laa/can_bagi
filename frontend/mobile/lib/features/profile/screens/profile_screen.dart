import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(title: 'PROFİLİM'),
          body: auth.isLoggedIn
              ? _LoggedInView(auth: auth)
              : const _GuestView(),
        );
      },
    );
  }
}

// ── Misafir Görünümü ────────────────────────────────────────────────────────
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
          const SizedBox(height: 16),
          const _AdvItem(Icons.bloodtype_outlined,  'Kan grubunuz kurtarma ekibine iletilir'),
          const _AdvItem(Icons.medication_outlined, 'Kronik ilaçlarınız bildirilir'),
          const _AdvItem(Icons.task_alt_outlined,   'Görev alabilirsiniz'),
          const SizedBox(height: 32),
          AppButton(
            label:     'KAYIT OL',
            onPressed: () => context.push('/register'),
          ),
          const SizedBox(height: 12),
          AppButton(
            label:    'GİRİŞ YAP',
            variant:  AppButtonVariant.outline,
            onPressed: () => context.push('/login'),
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

// ── Kayıtlı Kullanıcı Görünümü ───────────────────────────────────────────────
class _LoggedInView extends StatefulWidget {
  final AuthProvider auth;
  const _LoggedInView({required this.auth});

  @override
  State<_LoggedInView> createState() => _LoggedInViewState();
}

class _LoggedInViewState extends State<_LoggedInView> {
  late TextEditingController _nameCtr;
  late TextEditingController _surnameCtr;
  late TextEditingController _phoneCtr;
  String _bloodType = 'A+';

  static const List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.auth.user!;
    _nameCtr    = TextEditingController(text: u.name);
    _surnameCtr = TextEditingController(text: u.surname);
    _phoneCtr   = TextEditingController(text: u.phone);
    _bloodType  = _bloodTypes.contains(u.bloodType) ? u.bloodType : 'A+';

    // Sayfa açılınca otomatik GET /user/profile
    widget.auth.fetchProfile().then((_) {
      if (mounted && widget.auth.user != null) {
        final fresh = widget.auth.user!;
        _nameCtr.text = fresh.name;
        _surnameCtr.text = fresh.surname;
        _phoneCtr.text = fresh.phone;
        setState(() {
          _bloodType = _bloodTypes.contains(fresh.bloodType) ? fresh.bloodType : 'A+';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _surnameCtr.dispose();
    _phoneCtr.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await widget.auth.updateProfile(
        name:      _nameCtr.text.trim(),
        surname:   _surnameCtr.text.trim(),
        bloodType: _bloodType,
      );
      if (mounted) {
        AppToast.show(context, 'Profil güncellendi',
            type: AppToastType.success);
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          e.toString().replaceFirst('Exception: ', ''),
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title:   Text('Çıkış Yap', style: AppTextStyles.cardTitle),
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
            child: Text('Çıkış Yap',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.go('/');
      await widget.auth.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.auth.user?.name.substring(0, 1).toUpperCase() ?? '?',
              style: AppTextStyles.hero.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),

          AppTextField(
            label:      'İsim',
            controller: _nameCtr,
          ),
          const SizedBox(height: 12),

          AppTextField(
            label:      'Soyisim',
            controller: _surnameCtr,
          ),
          const SizedBox(height: 12),

          AppTextField(
            label:      'Telefon',
            controller: _phoneCtr,
            readOnly:   true,
          ),
          const SizedBox(height: 12),

          // Kan Grubu Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kan Grubu',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textDisabled),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:         _bloodType,
                    isExpanded:    true,
                    dropdownColor: AppColors.card,
                    icon: const Icon(Icons.expand_more,
                        color: AppColors.textSecondary),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    items: _bloodTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _bloodType = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Consumer<AuthProvider>(
            builder: (_, auth, __) => AppButton(
              label:     'KAYDET',
              isLoading: auth.isLoading,
              onPressed: _save,
            ),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: _logout,
            child: Text(
              'Çıkış Yap',
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
