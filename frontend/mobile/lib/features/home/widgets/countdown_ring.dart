import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Turuncu halka + geri sayım sayısı
class CountdownRing extends StatelessWidget {
  final Animation<double> progress; // 0.0 → 1.0 (3sn boyunca)
  final int               countdown; // 3, 2, 1
  final double            buttonSize;

  const CountdownRing({
    super.key,
    required this.progress,
    required this.countdown,
    required this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        final t         = progress.value;                  // 0→1
        final ringSize  = buttonSize * (1.0 + 0.55 * t);  // button → 1.55x
        final opacity   = 1.0 - t * 0.85;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: SizedBox(
            width: ringSize,
            height: ringSize,
            child: CustomPaint(
              painter: _RingPainter(progress: t),
              child: Center(
                child: Text(
                  '$countdown',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: buttonSize * 0.38,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = AppColors.accent
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap   = StrokeCap.round;

    final rect   = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final sweep  = 2 * math.pi * progress;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
