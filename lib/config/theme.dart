import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';

/// Application theme configuration for light and dark modes.
/// 
/// Provides pre-configured [ThemeData] objects using Material 3 design
/// with the app's brand colors.
class AppTheme {
  /// Private constructor to prevent instantiation.
  AppTheme._();

  /// Light theme configuration.
  /// 
  /// Uses Material 3 design with light brightness and generates a color
  /// scheme from [AppColors.primary].
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
  );

  /// Dark theme configuration.
  /// 
  /// Uses Material 3 design with dark brightness and generates a color
  /// scheme from [AppColors.primary].
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
  );
}
