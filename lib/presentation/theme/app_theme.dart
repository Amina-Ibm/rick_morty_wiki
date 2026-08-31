import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF091413);
  static const Color primary = Color(0xFF408A71);
  static const Color secondary = Color(0xFF285A48);
  static const Color creamText = Color(0xFFFBFBF9);

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: secondary,
        // ignore: deprecated_member_use
        background: background,
      ),
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: creamText, displayColor: creamText),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: creamText),
        titleTextStyle: GoogleFonts.montserrat(
          color: creamText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondary.withValues(alpha: 0.1).withAlpha(100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: creamText,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: creamText,
        // ignore: deprecated_member_use
        background: creamText,
      ),
      textTheme: GoogleFonts.montserratTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: background, displayColor: background),
      appBarTheme: AppBarTheme(
        backgroundColor: creamText,
        elevation: 0,
        iconTheme: const IconThemeData(color: background),
        titleTextStyle: GoogleFonts.montserrat(
          color: background,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondary.withValues(alpha: 0.1).withAlpha(100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
