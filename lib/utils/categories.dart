/// Category constants and UI helpers: names, list, icon, and color per category.
///
/// Import this file in widget/screen code that needs icon or color access on
/// [TransactionCategory]. The [TransactionCategoryUi] extension is only active
/// when this file is imported, keeping the domain model free of Flutter.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

export 'package:ase485_capstone_finance_ml/models/transaction.dart'
    show TransactionCategory;

/// UI-layer extension on [TransactionCategory].
///
/// Provides [icon] and [color] without coupling the domain enum to Flutter.
/// Widgets must import this file (lib/utils/categories.dart) to activate it.
extension TransactionCategoryUi on TransactionCategory {
  /// Display icon for this category.
  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.bills:
        return Icons.receipt_long;
      case TransactionCategory.shopping:
        return Icons.shopping_bag;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.healthcare:
        return Icons.local_hospital;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.other:
        return Icons.attach_money;
    }
  }

  /// Display color for this category.
  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return const Color(0xFFFF9800);
      case TransactionCategory.entertainment:
        return const Color(0xFF009688);
      case TransactionCategory.bills:
        return const Color(0xFFF44336);
      case TransactionCategory.shopping:
        return const Color(0xFF9C27B0);
      case TransactionCategory.transportation:
        return const Color(0xFF2196F3);
      case TransactionCategory.healthcare:
        return const Color(0xFFE91E63);
      case TransactionCategory.education:
        return const Color(0xFF3F51B5);
      case TransactionCategory.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// Category label constants and string-based icon/color lookup.
///
/// Delegates to [TransactionCategoryUi] so a single source of truth exists.
/// The string-based API is retained for view models that store plain [String]
/// categories (e.g. [CategoryBreakdown], [Recommendation]).
class Categories {
  Categories._();

  static const String food = 'Food';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills';
  static const String shopping = 'Shopping';
  static const String transportation = 'Transportation';
  static const String healthcare = 'Healthcare';
  static const String education = 'Education';
  static const String other = 'Other';

  /// All category display labels in order (for dropdowns and filter chips).
  static List<String> get all =>
      TransactionCategory.values.map((c) => c.label).toList();

  /// Returns the [IconData] for [category] string.
  static IconData icon(String category) =>
      TransactionCategory.fromName(category).icon;

  /// Returns the [Color] for [category] string.
  static Color color(String category) =>
      TransactionCategory.fromName(category).color;
}
