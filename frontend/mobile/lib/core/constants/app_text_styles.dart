import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle hero = GoogleFonts.bebasNeue(
    fontSize: 48,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  static TextStyle pageTitle = GoogleFonts.bebasNeue(
    fontSize: 32,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle cardTitle = GoogleFonts.bebasNeue(
    fontSize: 24,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
  );

  static TextStyle buttonText = GoogleFonts.bebasNeue(
    fontSize: 20,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static TextStyle label = GoogleFonts.bebasNeue(
    fontSize: 18,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
  );

  static TextStyle body = GoogleFonts.nunito(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle caption = GoogleFonts.nunito(
    fontSize: 14,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle small = GoogleFonts.nunito(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );
}
