import 'package:flutter/material.dart';

class MethodistTheme {
  // ============================================================================
  // COLORS
  // ============================================================================

  static const Color primaryRed = Color(0xFFDC143C);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFFF5722);

  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color black = Color(0xFF000000);

  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFDD6B20);
  static const Color infoBlue = Color(0xFF3182CE);

  // ============================================================================
  // RESPONSIVE SPACING - Base values (scale on different devices)
  // ============================================================================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ============================================================================
  // RESPONSIVE RADIUS
  // ============================================================================

  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 32.0;

  // ============================================================================
  // PADDING (Static - for backward compatibility)
  // ============================================================================

  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);
  static const EdgeInsets paddingXXL = EdgeInsets.all(spacingXXL);

  // ============================================================================
  // MARGIN (Static - for backward compatibility)
  // ============================================================================

  static const EdgeInsets marginXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets marginS = EdgeInsets.all(spacingS);
  static const EdgeInsets marginM = EdgeInsets.all(spacingM);
  static const EdgeInsets marginL = EdgeInsets.all(spacingL);
  static const EdgeInsets marginXL = EdgeInsets.all(spacingXL);

  // ============================================================================
  // TEXT STYLES - Display
  // ============================================================================

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: darkGray,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkGray,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );

  // ============================================================================
  // TEXT STYLES - Headline
  // ============================================================================

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );

  // ============================================================================
  // TEXT STYLES - Title
  // ============================================================================

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: darkGray,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: darkGray,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: darkGray,
  );

  // ============================================================================
  // TEXT STYLES - Body
  // ============================================================================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkGray,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: darkGray,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: darkGray,
  );

  // ============================================================================
  // TEXT STYLES - Label
  // ============================================================================

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: mediumGray,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: mediumGray,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: mediumGray,
  );

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryRed,
    foregroundColor: white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: primaryRed,
    side: const BorderSide(color: primaryRed),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryRed,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  static final ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorRed,
    foregroundColor: white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: spacingL,
      vertical: spacingM,
    ),
  );

  // ============================================================================
  // RESPONSIVE UTILITY METHODS
  // ============================================================================

  /// Get responsive spacing based on screen width
  /// Base screen width: 375 (iPhone SE)
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseSpacing * scaleFactor.clamp(0.8, 1.2);
  }

  /// Get responsive font size based on screen width
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseFontSize * scaleFactor.clamp(0.85, 1.25);
  }

  /// Get responsive border radius based on screen width
  static double responsiveRadius(BuildContext context, double baseRadius) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseRadius * scaleFactor.clamp(0.8, 1.2);
  }

  /// Get responsive padding based on screen width
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

  /// Get responsive icon size based on screen width
  static double responsiveIconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.sizeOf(context).width;
    final scaleFactor = width / 375;
    return baseSize * scaleFactor.clamp(0.9, 1.3);
  }

  // ============================================================================
  // RESPONSIVE TEXT STYLES
  // ============================================================================

  static TextStyle responsiveDisplayLarge(BuildContext context) {
    return displayLarge.copyWith(
      fontSize: responsiveFontSize(context, 32),
    );
  }

  static TextStyle responsiveDisplayMedium(BuildContext context) {
    return displayMedium.copyWith(
      fontSize: responsiveFontSize(context, 28),
    );
  }

  static TextStyle responsiveDisplaySmall(BuildContext context) {
    return displaySmall.copyWith(
      fontSize: responsiveFontSize(context, 24),
    );
  }

  static TextStyle responsiveHeadlineLarge(BuildContext context) {
    return headlineLarge.copyWith(
      fontSize: responsiveFontSize(context, 22),
    );
  }

  static TextStyle responsiveHeadlineMedium(BuildContext context) {
    return headlineMedium.copyWith(
      fontSize: responsiveFontSize(context, 20),
    );
  }

  static TextStyle responsiveHeadlineSmall(BuildContext context) {
    return headlineSmall.copyWith(
      fontSize: responsiveFontSize(context, 18),
    );
  }

  static TextStyle responsiveTitleLarge(BuildContext context) {
    return titleLarge.copyWith(
      fontSize: responsiveFontSize(context, 16),
    );
  }

  static TextStyle responsiveTitleMedium(BuildContext context) {
    return titleMedium.copyWith(
      fontSize: responsiveFontSize(context, 14),
    );
  }

  static TextStyle responsiveTitleSmall(BuildContext context) {
    return titleSmall.copyWith(
      fontSize: responsiveFontSize(context, 12),
    );
  }

  static TextStyle responsiveBodyLarge(BuildContext context) {
    return bodyLarge.copyWith(
      fontSize: responsiveFontSize(context, 16),
    );
  }

  static TextStyle responsiveBodyMedium(BuildContext context) {
    return bodyMedium.copyWith(
      fontSize: responsiveFontSize(context, 14),
    );
  }

  static TextStyle responsiveBodySmall(BuildContext context) {
    return bodySmall.copyWith(
      fontSize: responsiveFontSize(context, 12),
    );
  }

  static TextStyle responsiveLabelLarge(BuildContext context) {
    return labelLarge.copyWith(
      fontSize: responsiveFontSize(context, 14),
    );
  }

  static TextStyle responsiveLabelMedium(BuildContext context) {
    return labelMedium.copyWith(
      fontSize: responsiveFontSize(context, 12),
    );
  }

  static TextStyle responsiveLabelSmall(BuildContext context) {
    return labelSmall.copyWith(
      fontSize: responsiveFontSize(context, 10),
    );
  }

  // ============================================================================
  // DEVICE TYPE DETECTION
  // ============================================================================

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

  // ============================================================================
  // SNACKBAR METHODS
  // ============================================================================

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: white),
        ),
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
        content: Text(
          message,
          style: const TextStyle(color: white),
        ),
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
        content: Text(
          message,
          style: const TextStyle(color: white),
        ),
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
        content: Text(
          message,
          style: const TextStyle(color: white),
        ),
        backgroundColor: infoBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    );
  }

  // ============================================================================
  // THEME DATA
  // ============================================================================

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        surface: white,
      ),
      scaffoldBackgroundColor: lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
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
    );
  }
}

// ============================================================================
// THEME EXTENSION - Easy Access Methods
// ============================================================================

extension ThemeExtension on BuildContext {
  // ---- COLOR SHORTCUTS ----
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => MethodistTheme.lightRed;
  Color get backgroundColor => Theme.of(this).colorScheme.background;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get textPrimary => MethodistTheme.darkGray;
  Color get textSecondary => MethodistTheme.mediumGray;
  Color get successColor => MethodistTheme.successGreen;
  Color get warningColor => MethodistTheme.warningOrange;
  Color get errorColor => MethodistTheme.errorRed;
  Color get infoColor => MethodistTheme.infoBlue;

  // ---- SPACING SHORTCUTS ----
  double get spacingXS => MethodistTheme.spacingXS;
  double get spacingS => MethodistTheme.spacingS;
  double get spacingM => MethodistTheme.spacingM;
  double get spacingL => MethodistTheme.spacingL;
  double get spacingXL => MethodistTheme.spacingXL;
  double get spacingXXL => MethodistTheme.spacingXXL;

  // ---- RADIUS SHORTCUTS ----
  double get radiusXS => MethodistTheme.radiusXS;
  double get radiusS => MethodistTheme.radiusS;
  double get radiusM => MethodistTheme.radiusM;
  double get radiusL => MethodistTheme.radiusL;
  double get radiusXL => MethodistTheme.radiusXL;
  double get radiusXXL => MethodistTheme.radiusXXL;
  double get radiusXXXL => MethodistTheme.radiusXXXL;

  // ---- STATIC TEXT STYLES ----
  TextStyle get displayLarge => MethodistTheme.displayLarge;
  TextStyle get displayMedium => MethodistTheme.displayMedium;
  TextStyle get displaySmall => MethodistTheme.displaySmall;
  TextStyle get headlineLarge => MethodistTheme.headlineLarge;
  TextStyle get headlineMedium => MethodistTheme.headlineMedium;
  TextStyle get headlineSmall => MethodistTheme.headlineSmall;
  TextStyle get titleLarge => MethodistTheme.titleLarge;
  TextStyle get titleMedium => MethodistTheme.titleMedium;
  TextStyle get titleSmall => MethodistTheme.titleSmall;
  TextStyle get bodyLarge => MethodistTheme.bodyLarge;
  TextStyle get bodyMedium => MethodistTheme.bodyMedium;
  TextStyle get bodySmall => MethodistTheme.bodySmall;
  TextStyle get labelLarge => MethodistTheme.labelLarge;
  TextStyle get labelMedium => MethodistTheme.labelMedium;
  TextStyle get labelSmall => MethodistTheme.labelSmall;

  // ---- RESPONSIVE TEXT STYLES ----
  TextStyle get responsiveDisplayLarge =>
      MethodistTheme.responsiveDisplayLarge(this);
  TextStyle get responsiveDisplayMedium =>
      MethodistTheme.responsiveDisplayMedium(this);
  TextStyle get responsiveDisplaySmall =>
      MethodistTheme.responsiveDisplaySmall(this);
  TextStyle get responsiveHeadlineLarge =>
      MethodistTheme.responsiveHeadlineLarge(this);
  TextStyle get responsiveHeadlineMedium =>
      MethodistTheme.responsiveHeadlineMedium(this);
  TextStyle get responsiveHeadlineSmall =>
      MethodistTheme.responsiveHeadlineSmall(this);
  TextStyle get responsiveTitleLarge =>
      MethodistTheme.responsiveTitleLarge(this);
  TextStyle get responsiveTitleMedium =>
      MethodistTheme.responsiveTitleMedium(this);
  TextStyle get responsiveTitleSmall =>
      MethodistTheme.responsiveTitleSmall(this);
  TextStyle get responsiveBodyLarge =>
      MethodistTheme.responsiveBodyLarge(this);
  TextStyle get responsiveBodyMedium =>
      MethodistTheme.responsiveBodyMedium(this);
  TextStyle get responsiveBodySmall =>
      MethodistTheme.responsiveBodySmall(this);
  TextStyle get responsiveLabelLarge =>
      MethodistTheme.responsiveLabelLarge(this);
  TextStyle get responsiveLabelMedium =>
      MethodistTheme.responsiveLabelMedium(this);
  TextStyle get responsiveLabelSmall =>
      MethodistTheme.responsiveLabelSmall(this);

  // ---- RESPONSIVE UTILITY METHODS ----
  double responsiveSpacing(double baseSpacing) =>
      MethodistTheme.responsiveSpacing(this, baseSpacing);

  /// ✅ NEW: Get responsive spacing value (used in SizedBox)
  double spacing(double baseValue) {
    final width = MediaQuery.of(this).size.width;
    if (width < 360) return baseValue * 0.85;
    if (width < 480) return baseValue * 0.95;
    if (width < 600) return baseValue;
    if (width < 900) return baseValue * 1.05;
    return baseValue * 1.1;
  }

  double responsiveFontSize(double baseFontSize) =>
      MethodistTheme.responsiveFontSize(this, baseFontSize);

  double responsiveRadius(double baseRadius) =>
      MethodistTheme.responsiveRadius(this, baseRadius);

  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) =>
      MethodistTheme.responsivePadding(
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
      MethodistTheme.responsiveIconSize(this, baseSize);

  // ---- DEVICE TYPE DETECTION ----
  bool get isSmallPhone => MethodistTheme.isSmallPhone(this);
  bool get isPhone => MethodistTheme.isPhone(this);
  bool get isTablet => MethodistTheme.isTablet(this);
  bool get isDesktop => MethodistTheme.isDesktop(this);

  // ---- RESPONSIVE DATA ----
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

/// ============================================================================
/// RESPONSIVE DATA CLASS
/// ============================================================================

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
