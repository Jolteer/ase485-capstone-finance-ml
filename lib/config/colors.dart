/// App-wide color palette for branding and semantic UI.
///
/// Use [AppColors] for consistent colors: primary/brand, income (green),
/// expense (red), warning, success. Private constructor; use static members only.
import 'package:flutter/material.dart';

/// Static color constants for the app. Do not instantiate.
class AppColors {
  AppColors._();

  /// Main brand color; used for primary actions and app identity.
  static const Color primary = Color(0xFF2E7D32);

  /// Used for income entries and positive financial indicators.
  static const Color income = Color(0xFF2E7D32);

  /// Used for expense entries and negative financial indicators.
  static const Color expense = Color(0xFFD32F2F);

  /// Used for warnings, alerts, and caution states.
  static const Color warning = Color(0xFFF57C00);

  /// Used for success messages and completed states.
  static const Color success = Color(0xFF388E3C);
}
