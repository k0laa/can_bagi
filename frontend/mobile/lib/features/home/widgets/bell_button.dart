import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../services/sos_service.dart';

class BellButton extends StatefulWidget {
  const BellButton({super.key});

  @override
  State<BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<BellButton> {
  late final SosService _sosService;
  bool _isSirenPlaying = false;

  @override
  void initState() {
    super.initState();
    _sosService = SosService();
  }

  Future<void> _onBellPressStart() async {
    if (_isSirenPlaying) return;

    setState(() => _isSirenPlaying = true);
    HapticFeedback.mediumImpact();

    // Acil durum sirene sesini çal
    await _sosService.playEmergencySiren(looping: true);
  }

  Future<void> _onBellPressEnd() async {
    if (!_isSirenPlaying) return;

    // Sesi durdur
    await _sosService.stopAlertSound();

    setState(() => _isSirenPlaying = false);
  }

  @override
  void dispose() {
    // Çalıyorsa durdur
    if (_isSirenPlaying) {
      _sosService.stopAlertSound();
    }
    _sosService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onBellPressStart(),
      onLongPressEnd: (_) => _onBellPressEnd(),
      onLongPressCancel: _onBellPressEnd,
      child: AnimatedScale(
        scale: _isSirenPlaying ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isSirenPlaying ? AppColors.warning : AppColors.accent,
            boxShadow: [
              BoxShadow(
                color: (_isSirenPlaying ? AppColors.warning : AppColors.accent)
                    .withValues(alpha: 0.4),
                blurRadius: _isSirenPlaying ? 30 : 15,
                spreadRadius: _isSirenPlaying ? 5 : 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔔',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 2),
              Text(
                'ZİL',
                style: AppTextStyles.buttonText.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
