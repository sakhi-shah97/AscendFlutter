import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
            fontSize: 48, fontWeight: FontWeight.w600, color: AppColors.text, letterSpacing: -0.5),
        displayMedium: GoogleFonts.spaceGrotesk(
            fontSize: 34, fontWeight: FontWeight.w600, color: AppColors.text),
        displaySmall: GoogleFonts.spaceGrotesk(
            fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text),
        headlineMedium: GoogleFonts.spaceGrotesk(
            fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.text),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.text),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
      );

  static TextStyle numeric({double size = 22, Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color ?? AppColors.goldHigh);
}