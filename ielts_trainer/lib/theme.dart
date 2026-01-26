// lib/theme.dart
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.deepPurple,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Minecraft',
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepPurpleAccent,
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily: 'Minecraft',
  colorScheme: const ColorScheme.dark(primary: Colors.deepPurpleAccent),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurpleAccent,
      foregroundColor: Colors.white,
    ),
  ),
);
