import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';


class SosErrorScreen extends StatefulWidget {
  final String    message;
  final Future<void> Function() onRetry;

  const SosErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<SosErrorScreen> createState() => _SosErrorScreenState();
}

class _SosErrorScreenState extends State<SosErrorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _shake;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shake = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sallanan X ikonu
              AnimatedBuilder(
                animation: _shake,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shake.value * (1 - _ctrl.value), 0),
                  child: child,
                ),
                child: Container(
                  width:  120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.danger.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.danger, width: 3),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.danger,
                    size:  64,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Bağlantı Kurulamadı',
                style: AppTextStyles.pageTitle.copyWith(
                    color: AppColors.danger),
              ),

              const SizedBox(height: 12),

              Text(
                widget.message.isNotEmpty
                    ? widget.message
                    : 'İnternet bağlantınız yok ve ESP32 cihazı bulunamadı.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),

              const SizedBox(height: 48),

              AppButton(
                label:     'TEKRAR DENE',
                isLoading: _retrying,
                onPressed: () async {
                  setState(() => _retrying = true);
                  await widget.onRetry();
                  if (mounted) setState(() => _retrying = false);
                },
              ),

              const SizedBox(height: 12),

              AppButton(
                label:    'İPTAL',
                variant:  AppButtonVariant.outline,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
