import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../services/sos_service.dart';

class ConfirmationScreen extends StatefulWidget {
  final SosResponse response;
  const ConfirmationScreen({super.key, required this.response});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
             '${dt.day.toString().padLeft(2, '0')} '
             '${dt.hour.toString().padLeft(2, '0')}:'
             '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Geri tuşu direkt ana sayfaya gitsin
      canPop: false,
      onPopInvokedWithResult: (_, __) => context.go('/'),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Büyüyen yeşil checkmark
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width:  120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.15),
                        border: Border.all(color: AppColors.success, width: 3),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size:  64,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text('Sinyal İletildi',
                    style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.success)),

                const SizedBox(height: 16),

                Text(
                  widget.response.message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: 24),

                _InfoRow(
                  icon:  Icons.tag,
                  label: 'Çağrı No',
                  value: '#${widget.response.id}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon:  Icons.access_time,
                  label: 'Zaman',
                  value: _formatDate(widget.response.receivedAt),
                ),

                const SizedBox(height: 48),

                AppButton(
                  label:     'TAMAM',
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textDisabled, size: 16),
        const SizedBox(width: 6),
        Text('$label: ', style: AppTextStyles.caption),
        Text(value,
            style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
