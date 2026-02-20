import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg       = Color(0xFF07070D);
  static const surface  = Color(0xFF0F0F1A);
  static const surface2 = Color(0xFF16162A);
  static const border   = Color(0xFF1E1E3A);
  static const accent   = Color(0xFF00E5FF);
  static const accent2  = Color(0xFF7B2FFF);
  static const green    = Color(0xFF00FF88);
  static const red      = Color(0xFFFF3366);
  static const yellow   = Color(0xFFFFD600);
  static const muted    = Color(0xFF5A5A8A);
  static const text     = Color(0xFFE8E8FF);
}

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.accent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      surface: AppColors.surface,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.spaceMonoTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyMedium: GoogleFonts.spaceMono(color: AppColors.text, fontSize: 13),
      bodySmall:  GoogleFonts.spaceMono(color: AppColors.muted, fontSize: 11),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.bg,
        textStyle: GoogleFonts.spaceMono(fontWeight: FontWeight.bold, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.accent,
      thumbColor: AppColors.accent,
      inactiveTrackColor: AppColors.border,
      overlayColor: Color(0x2200E5FF),
    ),
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.accent),
    ),
  );
}
