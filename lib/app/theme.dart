import 'package:flutter/material.dart';

class MethodistTheme {
  // ============ COLORS ============

  // Primary colors
  static const Color primaryRed = Color(0xFFBF0A30);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color lightRed = Color(0xFFE57373);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color darkGray = Color(0xFF333333);
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFFF0F0F0);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  static const Color cardGray = Color(0xFFFAFAFA);

  // Status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // ============ SPACING ============
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ============ BORDER RADIUS ============
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;

  // ============ TEXT STYLES ============
  static const TextStyle displayLarge = TextStyle(
    color: black,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    color: black,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    color: black,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    color: black,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    color: black,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    color: primaryRed,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    color: darkGray,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    color: darkGray,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: darkGray,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: darkGray,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: mediumGray,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    color: primaryRed,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    color: darkGray,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    color: mediumGray,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ============ BUTTON STYLES ============
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryRed,
    foregroundColor: white,
    disabledBackgroundColor: mediumGray,
    disabledForegroundColor: white,
    elevation: 2,
    shadowColor: primaryRed.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      letterSpacing: 0.5,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    minimumSize: const Size(120, 48),
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primaryRed,
    disabledForegroundColor: mediumGray,
    side: const BorderSide(color: primaryRed, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.5,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    minimumSize: const Size(120, 48),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: primaryRed,
    disabledForegroundColor: mediumGray,
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.5,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: errorRed,
    foregroundColor: white,
    disabledBackgroundColor: mediumGray,
    disabledForegroundColor: white,
    elevation: 2,
    shadowColor: errorRed.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusM),
    ),
    textStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      letterSpacing: 0.5,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    minimumSize: const Size(120, 48),
  );

  // ============ MAIN THEME DATA ============
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: backgroundGray,
      fontFamily: 'Roboto',

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        secondary: darkRed,
        surface: white,
        error: errorRed,
        outline: lightGray,
        outlineVariant: lightGray.withOpacity(0.5),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black26,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
        iconTheme: IconThemeData(color: white, size: 24),
        actionsIconTheme: IconThemeData(color: white, size: 24),
      ),

      // Card theme - FIXED
      cardTheme: CardThemeData(
        color: white,
        shadowColor: Colors.black12,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: const TextStyle(color: mediumGray, fontSize: 14),
        hintStyle: const TextStyle(color: mediumGray, fontSize: 14),
        errorStyle: const TextStyle(color: errorRed, fontSize: 12),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryRed,
        size: 24,
      ),

      // Tab bar theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryRed,
        unselectedLabelColor: mediumGray,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryRed, width: 3),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        deleteIconColor: primaryRed,
        disabledColor: mediumGray,
        selectedColor: primaryRed,
        secondarySelectedColor: lightRed,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: darkGray,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        secondaryLabelStyle: const TextStyle(
          color: white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),

      // Dialog theme - FIXED
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        titleTextStyle: headlineMedium,
        contentTextStyle: bodyLarge,
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkGray,
        contentTextStyle: const TextStyle(
          color: white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        actionTextColor: primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 1,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryRed,
        linearTrackColor: lightGray,
        circularTrackColor: lightGray,
      ),
    );
  }

  // ============ UTILITY METHODS ============

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'approved':
      case 'active':
        return successGreen;
      case 'warning':
      case 'pending':
        return warningOrange;
      case 'error':
      case 'rejected':
      case 'inactive':
        return errorRed;
      case 'info':
      default:
        return infoBlue;
    }
  }

  // Common shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Common padding/margin constants
  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);

  static const EdgeInsets marginXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets marginS = EdgeInsets.all(spacingS);
  static const EdgeInsets marginM = EdgeInsets.all(spacingM);
  static const EdgeInsets marginL = EdgeInsets.all(spacingL);
  static const EdgeInsets marginXL = EdgeInsets.all(spacingXL);

  // Horizontal/Vertical padding
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: spacingS);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: spacingM);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: spacingL);

  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: spacingS);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: spacingL);
}

// Extension methods for easy theme access
extension MethodistThemeExtensions on BuildContext {
  // Colors
  Color get primaryColor => MethodistTheme.primaryRed;
  Color get backgroundColor => MethodistTheme.backgroundGray;
  Color get surfaceColor => MethodistTheme.white;
  Color get errorColor => MethodistTheme.errorRed;
  Color get successColor => MethodistTheme.successGreen;
  Color get warningColor => MethodistTheme.warningOrange;

  // Text colors
  Color get textPrimary => MethodistTheme.darkGray;
  Color get textSecondary => MethodistTheme.mediumGray;

  // Text styles
  TextStyle get displayLarge => MethodistTheme.displayLarge;
  TextStyle get displayMedium => MethodistTheme.displayMedium;
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

  // Spacing
  double get spacingXS => MethodistTheme.spacingXS;
  double get spacingS => MethodistTheme.spacingS;
  double get spacingM => MethodistTheme.spacingM;
  double get spacingL => MethodistTheme.spacingL;
  double get spacingXL => MethodistTheme.spacingXL;
  double get spacingXXL => MethodistTheme.spacingXXL;

  // Border radius - FIXED: Added missing radiusXXL
  double get radiusS => MethodistTheme.radiusS;
  double get radiusM => MethodistTheme.radiusM;
  double get radiusL => MethodistTheme.radiusL;
  double get radiusXL => MethodistTheme.radiusXL;
  double get radiusXXL => MethodistTheme.radiusXXL; // FIXED: This was missing!

  // Helper methods
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: successColor,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: errorColor,
      ),
    );
  }
}