import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF2C3E50); // Midnight Blue
const Color secondaryColor = Color(0xFFE74C3C); // Alizarin
const Color backgroundColor = Color(0xFFECF0F1); // Clouds
const Color textColor = Color(0xFF34495E); // Wet Asphalt

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    secondary: secondaryColor,
    surface: backgroundColor,
    onSurface: textColor,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.latoTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
      bodyLarge: TextStyle(fontSize: 16, color: textColor),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  cardTheme: CardThemeData(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
  ),
);
