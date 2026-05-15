import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../services/sos_service.dart';

class ConfirmationScreen extends StatefulWidget {
  final SosResponse response;
  final String? category;
  const ConfirmationScreen({super.key, required this.response, this.category});

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

  Color _getColor() {
    switch (widget.category) {
      case 'SOS': return AppColors.danger;
      case 'RESCUE': return AppColors.accent;
      case 'MEDICAL': return Colors.blue;
      case 'FOOD': return AppColors.success;
      case 'SHELTER': return Colors.amber;
      case 'CLOTHES': return Colors.blue;
      case 'VULNERABLE': return Colors.purple;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
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
                        color: color.withValues(alpha: 0.15),
                        border: Border.all(color: color, width: 3),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: color,
                        size:  64,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Text('Sinyal İletildi',
                    style: AppTextStyles.pageTitle.copyWith(
                        color: color)),

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
