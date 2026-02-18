import 'package:flutter/material.dart';

/// Centralised color palette used throughout the SmartSpend application.
///
/// Colours are grouped into:
/// 1. **Brand** – primary greens that align with the finance/money motif.
/// 2. **Accent** – secondary blues that convey trust.
/// 3. **Semantic** – colours reserved for specific meaning (income, expense, etc.).
/// 4. **Category palette** – a fixed list of colours mapped to spending
///    categories in charts and cards.
///
/// Private constructor prevents instantiation; use via `AppColors.primary`.
class AppColors {
  AppColors._();

  // ── Brand colours ─────────────────────────────────────────────────────
  /// Main brand colour – a dark green representing finance/money.
  static const Color primary = Color(0xFF2E7D32);

  /// A lighter variant of [primary] for hover states, highlights, etc.
  static const Color primaryLight = Color(0xFF60AD5E);

  /// A darker variant of [primary] for pressed states, borders, etc.
  static const Color primaryDark = Color(0xFF005005);

  // ── Accent colours ────────────────────────────────────────────────────
  /// Accent blue – used for secondary actions, links, or info elements.
  static const Color accent = Color(0xFF1565C0);

  /// Lighter accent for backgrounds or disabled accent states.
  static const Color accentLight = Color(0xFF5E92F3);

  // ── Semantic colours ──────────────────────────────────────────────────
  /// Green used to indicate positive amounts (income, savings).
  static const Color income = Color(0xFF388E3C);

  /// Red used to indicate negative amounts (expenses, overspend).
  static const Color expense = Color(0xFFC62828);

  /// Yellow/amber used for budget warnings (approaching limit).
  static const Color warning = Color(0xFFF9A825);

  /// Blue used for informational banners and tooltips.
  static const Color info = Color(0xFF0288D1);

  // ── Category palette (for pie/bar charts) ─────────────────────────────
  /// Each index maps to a spending category defined in utils/categories.dart.
  static const List<Color> categoryPalette = [
    Color(0xFF2E7D32), // Food
    Color(0xFF1565C0), // Entertainment
    Color(0xFFC62828), // Bills
    Color(0xFFF9A825), // Shopping
    Color(0xFF6A1B9A), // Transportation
    Color(0xFF00838F), // Healthcare
    Color(0xFFEF6C00), // Education
    Color(0xFF4E342E), // Other
  ];
}
