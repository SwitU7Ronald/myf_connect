import 'package:flutter/material.dart';

class MethodistTheme {
  // Colors
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

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusXXXL = 32.0;

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);
  static const EdgeInsets paddingXXL = EdgeInsets.all(spacingXXL);

  // Margin
  static const EdgeInsets marginXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets marginS = EdgeInsets.all(spacingS);
  static const EdgeInsets marginM = EdgeInsets.all(spacingM);
  static const EdgeInsets marginL = EdgeInsets.all(spacingL);
  static const EdgeInsets marginXL = EdgeInsets.all(spacingXL);

  // Text Styles
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

  // Button Styles
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

  // Static utility methods for SnackBars
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MethodistTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MethodistTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MethodistTheme.warningOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MethodistTheme.infoBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Theme Data
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

// Extension methods for easy access to theme properties
extension ThemeExtension on BuildContext {
  // Colors
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => MethodistTheme.lightRed;
  Color get backgroundColor => Theme.of(this).colorScheme.background;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get textPrimary => MethodistTheme.darkGray;
  Color get textSecondary => MethodistTheme.mediumGray;
  Color get successColor => MethodistTheme.successGreen;
  Color get warningColor => MethodistTheme.warningOrange;
  Color get errorColor => MethodistTheme.errorRed;
  Color get infoBlue => MethodistTheme.infoBlue;

  // Spacing
  double get spacingXS => MethodistTheme.spacingXS;
  double get spacingS => MethodistTheme.spacingS;
  double get spacingM => MethodistTheme.spacingM;
  double get spacingL => MethodistTheme.spacingL;
  double get spacingXL => MethodistTheme.spacingXL;
  double get spacingXXL => MethodistTheme.spacingXXL;

  // Radius
  double get radiusXS => MethodistTheme.radiusXS;
  double get radiusS => MethodistTheme.radiusS;
  double get radiusM => MethodistTheme.radiusM;
  double get radiusL => MethodistTheme.radiusL;
  double get radiusXL => MethodistTheme.radiusXL;
  double get radiusXXL => MethodistTheme.radiusXXL;

  // Text Styles
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
}
