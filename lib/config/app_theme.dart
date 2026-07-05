import 'package:flutter/material.dart';

class AppTheme {

  // ===========================
  // COLORS
  // ===========================

  static const Color primaryColor = Color(0xFF800020);      // Maroon
  static const Color secondaryColor = Color(0xFFA52A2A);    // Brown Red
  static const Color backgroundColor = Color(0xFFF8F5F5);   // Light Cream
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D2D2D);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color errorColor = Color(0xFFC62828);

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    primaryColor: primaryColor,

    scaffoldBackgroundColor: backgroundColor,

    cardColor: cardColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
  );
}