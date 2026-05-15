import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget  child;
  final bool    hasAccentBorder;
  final Color?  borderColor;
  final double  borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.hasAccentBorder = false,
    this.borderColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasAccentBorder
            ? Border.all(
                color: borderColor ?? AppColors.accent,
                width: 1.5,
              )
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.accent.withValues(alpha: 0.1),
          child: card,
        ),
      );
    }

    return card;
  }
}
