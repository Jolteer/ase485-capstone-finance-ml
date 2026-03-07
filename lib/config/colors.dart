/// App-wide color palette for branding and semantic UI.
///
/// Use [AppColors] for consistent colors: primary/brand, income (green),
/// expense (red), warning, success. Private constructor; use static members only.
library;

import 'package:flutter/material.dart';

/// Static color constants for the app. Do not instantiate.
class AppColors {
  AppColors._();

  // Shared palette primitive — intentionally the same green for brand and income.
  static const Color _brandGreen = Color(0xFF2E7D32);

  /// Main brand color; used for primary actions and app identity.
  static const Color primary = _brandGreen;

  /// Used for income entries and positive financial indicators.
  static const Color income = _brandGreen;

  /// Used for expense entries and negative financial indicators.
  static const Color expense = Color(0xFFD32F2F);

  /// Used for warnings, alerts, and caution states.
  static const Color warning = Color(0xFFF57C00);

  /// Used for success messages and completed states.
  static const Color success = Color(0xFF388E3C);

  /// Semi-transparent black scrim shown behind the [LoadingOverlay] spinner.
  static const Color loadingBarrier = Color(0x42000000);
}
