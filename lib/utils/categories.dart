/// Category constants and UI helpers: names, list, icon, and color per category.
///
/// Used by transaction/budget/recommendation screens and dropdowns for consistent labels and styling.
import 'package:flutter/material.dart';

/// Category name constants and lookup for [icon] and [color] by name.
class Categories {
  Categories._();

  /// Food and groceries.
  static const String food = 'Food';

  /// Entertainment, subscriptions, hobbies.
  static const String entertainment = 'Entertainment';

  /// Utilities, rent, recurring bills.
  static const String bills = 'Bills';

  /// General shopping and retail.
  static const String shopping = 'Shopping';

  /// Gas, transit, car maintenance.
  static const String transportation = 'Transportation';

  /// Medical, pharmacy, health.
  static const String healthcare = 'Healthcare';

  /// Courses, books, training.
  static const String education = 'Education';

  /// Uncategorized or miscellaneous.
  static const String other = 'Other';

  /// All category names in display order (for dropdowns and filter chips).
  static const List<String> all = [
    food,
    entertainment,
    bills,
    shopping,
    transportation,
    healthcare,
    education,
    other,
  ];

  /// Returns the [IconData] for [category]; [other] and unknown use [Icons.attach_money].
  static IconData icon(String category) {
    return switch (category) {
      food => Icons.restaurant,
      entertainment => Icons.movie,
      bills => Icons.receipt_long,
      shopping => Icons.shopping_bag,
      transportation => Icons.directions_car,
      healthcare => Icons.local_hospital,
      education => Icons.school,
      _ => Icons.attach_money,
    };
  }

  /// Returns the [Color] for [category]; unknown uses [Colors.grey].
  static Color color(String category) {
    return switch (category) {
      food => Colors.orange,
      entertainment => Colors.teal,
      bills => Colors.red,
      shopping => Colors.purple,
      transportation => Colors.blue,
      healthcare => Colors.pink,
      education => Colors.indigo,
      _ => Colors.grey,
    };
  }
}
