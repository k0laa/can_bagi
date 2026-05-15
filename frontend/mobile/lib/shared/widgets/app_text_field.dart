import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String              label;
  final String?             hint;
  final bool                obscureText;
  final bool                readOnly;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType       keyboardType;
  final Widget?             suffix;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.obscureText    = false,
    this.readOnly       = false,
    this.controller,
    this.validator,
    this.keyboardType   = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller:    controller,
          obscureText:   obscureText,
          readOnly:      readOnly,
          validator:     validator,
          keyboardType:  keyboardType,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText:        hint,
            hintStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              color: AppColors.textDisabled,
            ),
            suffixIcon:   suffix,
            filled:       true,
            fillColor:    AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:   BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.textDisabled, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.danger, width: 1.5),
            ),
            errorStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}
