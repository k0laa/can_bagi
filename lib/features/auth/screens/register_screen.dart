import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../services/register_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtr    = TextEditingController();
  final _surnameCtr = TextEditingController();
  final _phoneCtr   = TextEditingController();
  final _passCtr    = TextEditingController();
  String _bloodType = 'A+';
  bool   _showPass  = false;

  static const List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'
  ];

  @override
  void dispose() {
    _nameCtr.dispose();
    _surnameCtr.dispose();
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.register(RegisterRequest(
        name:      _nameCtr.text.trim(),
        surname:   _surnameCtr.text.trim(),
        phone:     _phoneCtr.text.trim(),
        password:  _passCtr.text,
        bloodType: _bloodType,
      ));
      if (mounted) {
        AppToast.show(context, 'Kayıt başarılı! Hoş geldiniz.',
            type: AppToastType.success);
        context.go('/profile');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('KAYIT OL', style: AppTextStyles.cardTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Hesap Oluştur', style: AppTextStyles.pageTitle),
                const SizedBox(height: 4),
                Text(
                  'Bilgileriniz kurtarma ekiplerine iletilir.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 24),

                Row(children: [
                  Expanded(
                    child: AppTextField(
                      label:      'İsim',
                      hint:       'Ahmet',
                      controller: _nameCtr,
                      validator:  (v) =>
                          (v?.isEmpty ?? true) ? 'Boş bırakılamaz' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label:      'Soyisim',
                      hint:       'Yılmaz',
                      controller: _surnameCtr,
                      validator:  (v) =>
                          (v?.isEmpty ?? true) ? 'Boş bırakılamaz' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                AppTextField(
                  label:        'Telefon',
                  hint:         '05XX XXX XXXX',
                  controller:   _phoneCtr,
                  keyboardType: TextInputType.phone,
                  validator:    (v) {
                    if (v == null || v.isEmpty) return 'Boş bırakılamaz';
                    if (!RegExp(r'^05\d{9}$').hasMatch(v.trim())) {
                      return '05XX formatında girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label:       'Şifre',
                  hint:        '••••••',
                  controller:  _passCtr,
                  obscureText: !_showPass,
                  suffix: IconButton(
                    icon: Icon(
                      _showPass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Boş bırakılamaz';
                    if (v.length < 6) return 'En az 6 karakter olmalı';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.textDisabled, width: 1),
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
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _bloodType = v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => AppButton(
                    label:     'KAYIT OL',
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'Zaten hesabınız var mı? ',
                          style: AppTextStyles.caption,
                        ),
                        TextSpan(
                          text: 'Giriş Yap',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
