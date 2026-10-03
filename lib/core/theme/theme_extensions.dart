import 'package:flutter/material.dart';
import 'package:myf_connect/core/design_system/tokens/spacing.dart';
import 'package:myf_connect/core/design_system/tokens/radius.dart';
import 'package:myf_connect/core/design_system/tokens/shadows.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;

  const AppColorsExtension({
    required this.primary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
      covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension DesignSystemContextX on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
  TextTheme get typography => Theme.of(this).textTheme;
  
  // Spacing getters for convenience
  double get spacingXs => AppSpacing.xs;
  double get spacingSm => AppSpacing.sm;
  double get spacingMd => AppSpacing.md;
  double get spacingLg => AppSpacing.lg;
  double get spacingXl => AppSpacing.xl;
  double get spacingXxl => AppSpacing.xxl;

  // Radius getters
  BorderRadius get radiusSm => AppRadius.borderSm;
  BorderRadius get radiusMd => AppRadius.borderMd;
  BorderRadius get radiusLg => AppRadius.borderLg;
  BorderRadius get radiusXl => AppRadius.borderXl;
  BorderRadius get radiusCircular => AppRadius.borderCircular;
  
  // Shadows getters
  List<BoxShadow> get shadowSm => AppShadows.sm;
  List<BoxShadow> get shadowMd => AppShadows.md;
  List<BoxShadow> get shadowLg => AppShadows.lg;
}
