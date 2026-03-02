import 'package:flutter/material.dart';

/// Application color palette for consistent theming.
/// 
/// Defines brand colors and semantic colors used throughout the app
/// for finance-specific UI elements like income, expenses, and alerts.
class AppColors {
  /// Private constructor to prevent instantiation.
  AppColors._();

  /// Primary brand color (green).
  /// 
  /// Used as the main theme color throughout the application.
  static const Color primary = Color(0xFF2E7D32);

  /// Color representing income or positive balance (green).
  /// 
  /// Used for displaying income transactions and positive financial indicators.
  static const Color income = Color(0xFF2E7D32);
  
  /// Color representing expenses or negative balance (red).
  /// 
  /// Used for displaying expense transactions and budget overages.
  static const Color expense = Color(0xFFD32F2F);
  
  /// Warning color (orange).
  /// 
  /// Used for alerts and warnings about approaching budget limits.
  static const Color warning = Color(0xFFF57C00);
  
  /// Success color (green).
  /// 
  /// Used for success messages and completed goal indicators.
  static const Color success = Color(0xFF388E3C);
}
