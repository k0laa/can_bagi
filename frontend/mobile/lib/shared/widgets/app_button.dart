import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, danger, success, outline, ghost }

class AppButton extends StatelessWidget {
  final String          label;
  final VoidCallback?   onPressed;
  final AppButtonVariant variant;
  final bool            isLoading;
  final bool            fullWidth;
  final double          height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant  = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.height    = 56,
  });

  Color get _bgColor {
    switch (variant) {
      case AppButtonVariant.primary:  return AppColors.accent;
      case AppButtonVariant.danger:   return AppColors.danger;
      case AppButtonVariant.success:  return AppColors.success;
      case AppButtonVariant.outline:  return Colors.transparent;
      case AppButtonVariant.ghost:    return Colors.transparent;
    }
  }

  Color get _fgColor {
    switch (variant) {
      case AppButtonVariant.outline: return AppColors.accent;
      case AppButtonVariant.ghost:   return AppColors.textSecondary;
      default:                       return AppColors.textPrimary;
    }
  }

  BorderSide get _border {
    if (variant == AppButtonVariant.outline) {
      return const BorderSide(color: AppColors.accent, width: 1.5);
    }
    return BorderSide.none;
  }

  @override
  Widget build(BuildContext context) {
    final btn = SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _bgColor,
          foregroundColor: _fgColor,
          disabledBackgroundColor: AppColors.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _border,
          ),
          elevation: variant == AppButtonVariant.ghost ? 0 : 2,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.buttonText.copyWith(color: _fgColor),
              ),
      ),
    );

    return btn;
  }
}
