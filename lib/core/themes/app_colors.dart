import 'package:flutter/material.dart';

/// Semantic color tokens that adapt to light/dark mode.
class AppColors {
  final Brightness brightness;
  final ColorScheme colorScheme;

  AppColors._(this.brightness, this.colorScheme);

  factory AppColors.of(BuildContext context) {
    final theme = Theme.of(context);
    return AppColors._(theme.brightness, theme.colorScheme);
  }

  // Brand
  static const Color primaryRed = Color(0xFFDC143C);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFFF5722);

  // Semantic
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFDD6B20);
  static const Color infoBlue = Color(0xFF3182CE);

  // Theme-aware getters
  Color get surface => colorScheme.surface;
  Color get background => colorScheme.surfaceContainerLowest;
  Color get scaffoldBackground => brightness == Brightness.light
      ? const Color(0xFFF5F5F5)
      : const Color(0xFF121212);
  Color get cardColor =>
      brightness == Brightness.light ? Colors.white : const Color(0xFF1E1E1E);
  Color get textPrimary => brightness == Brightness.light
      ? const Color(0xFF424242)
      : const Color(0xFFE0E0E0);
  Color get textSecondary => brightness == Brightness.light
      ? const Color(0xFF9E9E9E)
      : const Color(0xFF9E9E9E);
  Color get dividerColor => brightness == Brightness.light
      ? const Color(0xFFE0E0E0)
      : const Color(0xFF424242);
  Color get iconColor => brightness == Brightness.light
      ? const Color(0xFF424242)
      : const Color(0xFFBDBDBD);
}
