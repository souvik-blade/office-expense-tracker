import 'package:flutter/material.dart';


class AppTheme {
  static const Color primary = Color(0xFF171D25);
  static const Color secondary  = Color(0xFFE11A28);
  static const Color card = Color(0xFF1F242C);
  static const Color background = Color(0xFF0f141a);
  static const Color indigoAccent = Color(0xFF4F46E5);


  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary ,
      surface: card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardColor: card,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondary ,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );


// basic light fallback (optional)
  static final lightTheme = ThemeData.light();
}