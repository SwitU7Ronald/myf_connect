import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _display(double size, FontWeight weight, double letterSpacing) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: weight, letterSpacing: letterSpacing);

  static TextStyle _body(double size, FontWeight weight, double letterSpacing) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, letterSpacing: letterSpacing);

  static final TextStyle displayLarge = _display(57, FontWeight.bold, -0.25);
  static final TextStyle displayMedium = _display(45, FontWeight.bold, 0);
  static final TextStyle displaySmall = _display(36, FontWeight.bold, 0);

  static final TextStyle headlineLarge = _display(32, FontWeight.bold, 0);
  static final TextStyle headlineMedium = _display(28, FontWeight.w600, 0);
  static final TextStyle headlineSmall = _display(24, FontWeight.w600, 0);

  static final TextStyle titleLarge = _display(22, FontWeight.w600, 0);
  static final TextStyle titleMedium = _body(16, FontWeight.w600, 0.15);
  static final TextStyle titleSmall = _body(14, FontWeight.w600, 0.1);

  static final TextStyle bodyLarge = _body(16, FontWeight.normal, 0.5);
  static final TextStyle bodyMedium = _body(14, FontWeight.normal, 0.25);
  static final TextStyle bodySmall = _body(12, FontWeight.normal, 0.4);

  static final TextStyle labelLarge = _body(14, FontWeight.w600, 0.1);
  static final TextStyle labelMedium = _body(12, FontWeight.w600, 0.5);
  static final TextStyle labelSmall = _body(11, FontWeight.w600, 0.5);
  
  static TextTheme getTextTheme(Color displayColor, Color bodyColor) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: displayColor),
      displayMedium: displayMedium.copyWith(color: displayColor),
      displaySmall: displaySmall.copyWith(color: displayColor),
      headlineLarge: headlineLarge.copyWith(color: displayColor),
      headlineMedium: headlineMedium.copyWith(color: displayColor),
      headlineSmall: headlineSmall.copyWith(color: displayColor),
      titleLarge: titleLarge.copyWith(color: displayColor),
      titleMedium: titleMedium.copyWith(color: displayColor),
      titleSmall: titleSmall.copyWith(color: displayColor),
      bodyLarge: bodyLarge.copyWith(color: bodyColor),
      bodyMedium: bodyMedium.copyWith(color: bodyColor),
      bodySmall: bodySmall.copyWith(color: bodyColor),
      labelLarge: labelLarge.copyWith(color: bodyColor),
      labelMedium: labelMedium.copyWith(color: bodyColor),
      labelSmall: labelSmall.copyWith(color: bodyColor),
    );
  }
}
