import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: eloraPrimary,
          brightness: Brightness.light,
        ).copyWith(
          primary: eloraPrimary,
          secondary: eloraPrimary,
          surface: eloraCard,
          onSurface: eloraDark,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: eloraBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: eloraPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(color: eloraCard),
      inputDecorationTheme: _inputs(eloraCard),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: eloraPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const accent = Color(0xFF55C9BE);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          primary: accent,
          secondary: accent,
          surface: eloraCard,
          onSurface: eloraDark,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: eloraBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: eloraBackground,
        foregroundColor: eloraDark,
        elevation: 0,
      ),
      cardTheme: CardThemeData(color: eloraCard),
      inputDecorationTheme: _inputs(eloraCard),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0D8A7D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputs(Color fill) => InputDecorationTheme(
    filled: true,
    fillColor: fill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: eloraInput),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: eloraPrimary, width: 1.4),
    ),
  );
}
