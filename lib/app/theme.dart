import 'package:flutter/material.dart';

class MethodistTheme {
  static const Color primaryRed = Color(0xFFBF0A30);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color darkGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFFF0F0F0);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: white,
      fontFamily: 'Roboto',

      appBarTheme: AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: white,
        elevation: 4,
        centerTitle: true,
        iconTheme: const IconThemeData(color: white),
        titleTextStyle: const TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: black,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: black,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: darkGray, fontSize: 16),
        bodyMedium: TextStyle(color: darkGray, fontSize: 14),
        titleMedium: TextStyle(color: primaryRed, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkGray, fontSize: 12),
      ),

      iconTheme: IconThemeData(color: primaryRed),

      cardTheme: CardThemeData(
        color: lightGray,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primaryRed,
        unselectedLabelColor: darkGray,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryRed, width: 3),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryRed, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: darkGray.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(color: darkGray),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
