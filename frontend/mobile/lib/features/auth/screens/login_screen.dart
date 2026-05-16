import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtr  = TextEditingController();
  final _passCtr   = TextEditingController();
  bool  _showPass  = false;

  @override
  void dispose() {
    _phoneCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    print("allah belamı versin  ");

    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    try {
          print(auth);
      
      await auth.login(_phoneCtr.text.trim(), _passCtr.text);
      if (mounted) {
        // Konum al ve profil güncelle (Giriş sonrası otomatik)
        try {
          final loc = context.read<LocationProvider>();
          print(loc);
          final pos = await loc.getCurrentPosition();
          
          print(pos);
          if (pos != null && auth.user != null) {
            
          print( auth.user);
            await auth.updateProfile(
              name: auth.user!.name,
              surname: auth.user!.surname,
              bloodType: auth.user!.bloodType,
              skills: auth.user!.skills,
              lat: pos.latitude,
              lon: pos.longitude,
            );
          }
        } catch (_) {}

        if (!mounted) return;
        AppToast.show(context, 'Hoş geldiniz, ${auth.user?.name}!',
            type: AppToastType.success);
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
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
        backgroundColor:  AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('GİRİŞ YAP', style: AppTextStyles.cardTitle),
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
                const SizedBox(height: 16),
                Text('Tekrar hoş geldiniz!', style: AppTextStyles.pageTitle),
                const SizedBox(height: 4),
                Text(
                  'Hesabınıza giriş yapın.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 32),

                AppTextField(
                  label:        'Telefon',
                  hint:         '05XX XXX XXXX',
                  controller:   _phoneCtr,
                  keyboardType: TextInputType.phone,
                  validator:    (v) {
                    if (v == null || v.isEmpty) return 'Telefon boş bırakılamaz';
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
                    if (v == null || v.isEmpty) return 'Şifre boş bırakılamaz';
                    if (v.length < 6) return 'En az 6 karakter olmalı';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => AppButton(
                    label:     'GİRİŞ YAP',
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hesabınız yok mu? ',
                            style: AppTextStyles.caption,
                          ),
                          TextSpan(
                            text: 'Kayıt Ol',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
