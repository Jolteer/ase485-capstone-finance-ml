/// App theme: light and dark [ThemeData] using Material 3.
///
/// [AppColors.primary] is the color scheme seed. Use [lightTheme] and [darkTheme]
/// with [MaterialApp.theme] and [MaterialApp.darkTheme]; theme mode can follow system.
library;
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';

/// Provides light and dark [ThemeData] for the app.
class AppTheme {
  AppTheme._();

  /// Light theme; use with [MaterialApp.theme].
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
  );

  /// Dark theme; use with [MaterialApp.darkTheme].
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
  );
}
