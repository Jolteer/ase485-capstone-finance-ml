import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';

/// Centralised theme configuration for the SmartSpend app.
///
/// Provides both a [lightTheme] and a [darkTheme]. Material 3 is enabled so
/// Flutter auto-generates a full color scheme from the single seed color
/// [AppColors.primary].
///
/// Private constructor (`AppTheme._()`) prevents instantiation – all members
/// are static, so this class acts as a namespace.
class AppTheme {
  AppTheme._();

  /// Light theme – used when the device is in light mode.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true, // Opt-in to Material 3 design tokens.
      brightness: Brightness.light,
      // Generates an entire ColorScheme from a single seed color.
      colorSchemeSeed: AppColors.primary,
      fontFamily: 'Roboto',
      // Centre the title in the AppBar and remove the drop-shadow.
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      // All Cards get rounded corners (12px radius) with a subtle shadow.
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Text fields are outlined with 8px rounded corners and a filled background.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }

  /// Dark theme – mirrors the light theme but uses [Brightness.dark].
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.primary,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }
}
