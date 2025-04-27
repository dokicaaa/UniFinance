import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // Enable Material 3 features
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 48, 70, 116),
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.poppinsTextTheme(), // All text uses Montserrat
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color.fromARGB(255, 48, 70, 116),
    secondary: Color.fromARGB(255, 78, 135, 255),
    tertiary: Color.fromARGB(255, 220, 230, 238),
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onError: Colors.white,
  ),
);
