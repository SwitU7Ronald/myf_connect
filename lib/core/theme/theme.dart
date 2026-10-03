import 'package:flutter/material.dart';
import 'package:myf_connect/core/design_system/tokens/typography.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';

/// Semantic color tokens that adapt to light/dark mode.
/// Use `AppColors.of(context)` in widgets, or access via the
/// `BuildContext` extension (e.g. `context.appColors`).
class AppColors {
  final Brightness brightness;
  final ColorScheme colorScheme;

  AppColors._(this.brightness, this.colorScheme);

  factory AppColors.of(BuildContext context) {
    final theme = Theme.of(context);
    return AppColors._(theme.brightness, theme.colorScheme);
  }

  // ── Brand ──────────────────────────────────────────────────────────
  static const Color primaryRed = Color(0xFF8B0000); // Crimson Cross & Flame
  static const Color darkRed = Color(0xFF5A0000);
  static const Color lightRed = Color(0xFFC41E3A); // Cardinal

  // ── Semantic (status) ──────────────────────────────────────────────
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFDD6B20);
  static const Color infoBlue = Color(0xFF3182CE);

  // ── Theme-aware getters ────────────────────────────────────────────
  Color get surface => colorScheme.surface;
  Color get background => colorScheme.surfaceContainerLowest;
  Color get scaffoldBackground => brightness == Brightness.light ? const Color(0xFFFAF9F6) /* Warm Cream */ : const Color(0xFF2F3E46); /* Liturgical Slate */
  Color get cardColor =>
      brightness == Brightness.light ? const Color(0xFFF5F2EB) /* Linen */ : const Color(0xFF354F52);
  Color get textPrimary => brightness == Brightness.light ? const Color(0xFF333333) /* Warm Charcoal */ : const Color(0xFFE8E8E8);
  Color get textSecondary => brightness == Brightness.light ? const Color(0xFF666666) : const Color(0xFFAAAAAA);
  Color get dividerColor => brightness == Brightness.light
      ? const Color(0xFFE0E0E0)
      : const Color(0xFF424242);
  Color get iconColor => brightness == Brightness.light
      ? const Color(0xFF424242)
      : const Color(0xFFBDBDBD);
}

class MyfTheme {
  MyfTheme._();

  // ── Brand colors (constant, don't change with theme) ───────────────
  static const Color primaryRed = AppColors.primaryRed;
  static const Color darkRed = AppColors.darkRed;
  static const Color lightRed = AppColors.lightRed;

  // Legacy color constants kept for backwards compat during migration.
  // Prefer using `AppColors.of(context)` or `context.appColors` instead.
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color black = Color(0xFF000000);

  static const Color errorRed = AppColors.errorRed;
  static const Color successGreen = AppColors.successGreen;
  static const Color warningOrange = AppColors.warningOrange;
  static const Color infoBlue = AppColors.infoBlue;

  // ── Spacing ────────────────────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ── Radius ─────────────────────────────────────────────────────────
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 32.0;

  // ── Padding / Margin helpers ───────────────────────────────────────
  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);
  static const EdgeInsets paddingXXL = EdgeInsets.all(spacingXXL);

  static const EdgeInsets marginXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets marginS = EdgeInsets.all(spacingS);
  static const EdgeInsets marginM = EdgeInsets.all(spacingM);
  static const EdgeInsets marginL = EdgeInsets.all(spacingL);
  static const EdgeInsets marginXL = EdgeInsets.all(spacingXL);

  // ── Text styles (no hardcoded color — theme handles it) ────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );

  // ── Button styles ──────────────────────────────────────────────────
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryRed,
    foregroundColor: white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: primaryRed,
    side: const BorderSide(color: primaryRed),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryRed,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  static final ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorRed,
    foregroundColor: white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
    padding: EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  // ── Responsive helpers ─────────────────────────────────────────────
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseSpacing * scaleFactor.clamp(0.8, 1.2);
  }

  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseFontSize * scaleFactor.clamp(0.85, 1.25);
  }

  static double responsiveRadius(BuildContext context, double baseRadius) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseRadius * scaleFactor.clamp(0.8, 1.2);
  }

  static EdgeInsets responsivePadding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    final scale = MediaQuery.sizeOf(context).width / 375;
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0) * scale,
      right: (right ?? horizontal ?? all ?? 0) * scale,
      top: (top ?? vertical ?? all ?? 0) * scale,
      bottom: (bottom ?? vertical ?? all ?? 0) * scale,
    );
  }

  static double responsiveIconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseSize * scaleFactor.clamp(0.9, 1.3);
  }

  static TextStyle responsiveDisplayLarge(BuildContext context) {
    return displayLarge.copyWith(fontSize: responsiveFontSize(context, 32));
  }

  static TextStyle responsiveDisplayMedium(BuildContext context) {
    return displayMedium.copyWith(fontSize: responsiveFontSize(context, 28));
  }

  static TextStyle responsiveDisplaySmall(BuildContext context) {
    return displaySmall.copyWith(fontSize: responsiveFontSize(context, 24));
  }

  static TextStyle responsiveHeadlineLarge(BuildContext context) {
    return headlineLarge.copyWith(fontSize: responsiveFontSize(context, 22));
  }

  static TextStyle responsiveHeadlineMedium(BuildContext context) {
    return headlineMedium.copyWith(fontSize: responsiveFontSize(context, 20));
  }

  static TextStyle responsiveHeadlineSmall(BuildContext context) {
    return headlineSmall.copyWith(fontSize: responsiveFontSize(context, 18));
  }

  static TextStyle responsiveTitleLarge(BuildContext context) {
    return titleLarge.copyWith(fontSize: responsiveFontSize(context, 16));
  }

  static TextStyle responsiveTitleMedium(BuildContext context) {
    return titleMedium.copyWith(fontSize: responsiveFontSize(context, 14));
  }

  static TextStyle responsiveTitleSmall(BuildContext context) {
    return titleSmall.copyWith(fontSize: responsiveFontSize(context, 12));
  }

  static TextStyle responsiveBodyLarge(BuildContext context) {
    return bodyLarge.copyWith(fontSize: responsiveFontSize(context, 16));
  }

  static TextStyle responsiveBodyMedium(BuildContext context) {
    return bodyMedium.copyWith(fontSize: responsiveFontSize(context, 14));
  }

  static TextStyle responsiveBodySmall(BuildContext context) {
    return bodySmall.copyWith(fontSize: responsiveFontSize(context, 12));
  }

  static TextStyle responsiveLabelLarge(BuildContext context) {
    return labelLarge.copyWith(fontSize: responsiveFontSize(context, 14));
  }

  static TextStyle responsiveLabelMedium(BuildContext context) {
    return labelMedium.copyWith(fontSize: responsiveFontSize(context, 12));
  }

  static TextStyle responsiveLabelSmall(BuildContext context) {
    return labelSmall.copyWith(fontSize: responsiveFontSize(context, 10));
  }

  // ── Device breakpoints ─────────────────────────────────────────────
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 900;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 900;
  }

  // ── Snack bars ─────────────────────────────────────────────────────
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: white)),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: white)),
        backgroundColor: errorRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: white)),
        backgroundColor: warningOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: white)),
        backgroundColor: infoBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        surface: white,
      ),
      extensions: const [
        AppColorsExtension(
          primary: AppColors.primaryRed,
          background: Color(0xFFF5F5F5),
          surface: Colors.white,
          textPrimary: Color(0xFF424242),
          textSecondary: Color(0xFF9E9E9E),
          divider: Color(0xFFE0E0E0),
          error: AppColors.errorRed,
          success: AppColors.successGreen,
          warning: AppColors.warningOrange,
          info: AppColors.infoBlue,
        ),
      ],
      scaffoldBackgroundColor: lightGray,
      textTheme: AppTypography.getTextTheme(const Color(0xFF424242), const Color(0xFF424242)),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: const Color(0xFF424242),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: const Color(0xFF333333),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: AppTypography.displayLarge.fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        margin: marginS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorRed),
        ),
        errorMaxLines: 3,
        contentPadding: paddingM,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryRed,
        unselectedLabelColor: mediumGray,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryRed, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkGray,
        contentTextStyle: const TextStyle(color: white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0)),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF2F3E46); // Deep Liturgical Slate
    const darkCard = Color(0xFF354F52);
    const darkElevated = Color(0xFF354F52);
    const darkTextPrimary = Color(0xFFE8E8E8);
    const darkTextSecondary = Color(0xFFAAAAAA);
    const darkBorder = Color(0xFF424242);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.dark,
        primary: primaryRed,
        surface: darkCard,
        onSurface: darkTextPrimary,
      ),
      extensions: const [
        AppColorsExtension(
          primary: AppColors.primaryRed,
          background: darkSurface,
          surface: darkCard,
          textPrimary: darkTextPrimary,
          textSecondary: darkTextSecondary,
          divider: darkBorder,
          error: AppColors.errorRed,
          success: AppColors.successGreen,
          warning: AppColors.warningOrange,
          info: AppColors.infoBlue,
        ),
      ],
      scaffoldBackgroundColor: darkSurface,
      textTheme: AppTypography.getTextTheme(darkTextPrimary, darkTextPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: AppTypography.displayLarge.fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 2,
        margin: marginS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorRed),
        ),
        errorMaxLines: 3,
        contentPadding: paddingM,
        hintStyle: const TextStyle(color: darkTextSecondary),
        labelStyle: const TextStyle(color: darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryRed,
        unselectedLabelColor: darkTextSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryRed, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkElevated,
        contentTextStyle: const TextStyle(color: darkTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: darkBorder),
    );
  }

  // Legacy alias — kept so old code still compiles.
  static ThemeData get theme => lightTheme;
}

// ── BuildContext Extension ─────────────────────────────────────────────
extension ThemeExtension on BuildContext {
  AppColors get appColors => AppColors.of(this);

  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => MyfTheme.lightRed;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get textPrimary => appColors.textPrimary;
  Color get textSecondary => appColors.textSecondary;
  Color get successColor => MyfTheme.successGreen;
  Color get warningColor => MyfTheme.warningOrange;
  Color get errorColor => MyfTheme.errorRed;
  Color get infoColor => MyfTheme.infoBlue;

  double get spacingXS => MyfTheme.spacingXS;
  double get spacingS => MyfTheme.spacingS;
  double get spacingM => MyfTheme.spacingM;
  double get spacingL => MyfTheme.spacingL;
  double get spacingXL => MyfTheme.spacingXL;
  double get spacingXXL => MyfTheme.spacingXXL;

  double get radiusXS => MyfTheme.radiusXS;
  double get radiusS => MyfTheme.radiusS;
  double get radiusM => MyfTheme.radiusM;
  double get radiusL => MyfTheme.radiusL;
  double get radiusXL => MyfTheme.radiusXL;
  double get radiusXXL => MyfTheme.radiusXXL;
  double get radiusXXXL => MyfTheme.radiusXXXL;

  TextStyle get displayLarge => MyfTheme.displayLarge;
  TextStyle get displayMedium => MyfTheme.displayMedium;
  TextStyle get displaySmall => MyfTheme.displaySmall;
  TextStyle get headlineLarge => MyfTheme.headlineLarge;
  TextStyle get headlineMedium => MyfTheme.headlineMedium;
  TextStyle get headlineSmall => MyfTheme.headlineSmall;
  TextStyle get titleLarge => MyfTheme.titleLarge;
  TextStyle get titleMedium => MyfTheme.titleMedium;
  TextStyle get titleSmall => MyfTheme.titleSmall;
  TextStyle get bodyLarge => MyfTheme.bodyLarge;
  TextStyle get bodyMedium => MyfTheme.bodyMedium;
  TextStyle get bodySmall => MyfTheme.bodySmall;
  TextStyle get labelLarge => MyfTheme.labelLarge;
  TextStyle get labelMedium => MyfTheme.labelMedium;
  TextStyle get labelSmall => MyfTheme.labelSmall;

  TextStyle get responsiveDisplayLarge => MyfTheme.responsiveDisplayLarge(this);
  TextStyle get responsiveDisplayMedium =>
      MyfTheme.responsiveDisplayMedium(this);
  TextStyle get responsiveDisplaySmall => MyfTheme.responsiveDisplaySmall(this);
  TextStyle get responsiveHeadlineLarge =>
      MyfTheme.responsiveHeadlineLarge(this);
  TextStyle get responsiveHeadlineMedium =>
      MyfTheme.responsiveHeadlineMedium(this);
  TextStyle get responsiveHeadlineSmall =>
      MyfTheme.responsiveHeadlineSmall(this);
  TextStyle get responsiveTitleLarge => MyfTheme.responsiveTitleLarge(this);
  TextStyle get responsiveTitleMedium => MyfTheme.responsiveTitleMedium(this);
  TextStyle get responsiveTitleSmall => MyfTheme.responsiveTitleSmall(this);
  TextStyle get responsiveBodyLarge => MyfTheme.responsiveBodyLarge(this);
  TextStyle get responsiveBodyMedium => MyfTheme.responsiveBodyMedium(this);
  TextStyle get responsiveBodySmall => MyfTheme.responsiveBodySmall(this);
  TextStyle get responsiveLabelLarge => MyfTheme.responsiveLabelLarge(this);
  TextStyle get responsiveLabelMedium => MyfTheme.responsiveLabelMedium(this);
  TextStyle get responsiveLabelSmall => MyfTheme.responsiveLabelSmall(this);

  double responsiveSpacing(double baseSpacing) =>
      MyfTheme.responsiveSpacing(this, baseSpacing);

  double spacing(double baseValue) {
    final width = MediaQuery.of(this).size.width;
    if (width < 360) return baseValue * 0.85;
    if (width < 480) return baseValue * 0.95;
    if (width < 600) return baseValue;
    if (width < 900) return baseValue * 1.05;
    return baseValue * 1.1;
  }

  double responsiveFontSize(double baseFontSize) =>
      MyfTheme.responsiveFontSize(this, baseFontSize);

  double responsiveRadius(double baseRadius) =>
      MyfTheme.responsiveRadius(this, baseRadius);

  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) => MyfTheme.responsivePadding(
    this,
    all: all,
    horizontal: horizontal,
    vertical: vertical,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
  );

  double responsiveIconSize(double baseSize) =>
      MyfTheme.responsiveIconSize(this, baseSize);

  bool get isSmallPhone => MyfTheme.isSmallPhone(this);
  bool get isPhone => MyfTheme.isPhone(this);
  bool get isTablet => MyfTheme.isTablet(this);
  bool get isDesktop => MyfTheme.isDesktop(this);

  ResponsiveData get responsive {
    final width = MediaQuery.of(this).size.width;
    return ResponsiveData(
      width: width,
      isSmall: width < 480,
      isMedium: width >= 480 && width < 900,
      isLarge: width >= 900,
      cardElevation: width < 480 ? 2 : 4,
    );
  }
}

class ResponsiveData {
  final double width;
  final bool isSmall;
  final bool isMedium;
  final bool isLarge;
  final double cardElevation;

  ResponsiveData({
    required this.width,
    required this.isSmall,
    required this.isMedium,
    required this.isLarge,
    required this.cardElevation,
  });
}
