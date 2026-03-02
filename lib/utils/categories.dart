import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/models.dart';

/// Utility class for managing spending categories and their visual representations.
/// 
/// Provides constants for category names, complete category list, and helper
/// methods to get icons and colors for each category.
class Categories {
  /// Private constructor to prevent instantiation.
  Categories._();

  /// Food and dining category.
  static const String food = 'Food';
  
  /// Entertainment and leisure category.
  static const String entertainment = 'Entertainment';
  
  /// Bills and utilities category.
  static const String bills = 'Bills';
  
  /// Shopping and retail category.
  static const String shopping = 'Shopping';
  
  /// Transportation and commute category.
  static const String transportation = 'Transportation';
  
  /// Healthcare and medical category.
  static const String healthcare = 'Healthcare';
  
  /// Education and learning category.
  static const String education = 'Education';
  
  /// Other miscellaneous category.
  static const String other = 'Other';

  /// Complete list of all available categories.
  /// 
  /// Used for dropdown menus and category filtering.
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

  /// Returns the icon representing the given category.
  /// 
  /// Maps each category to an appropriate Material icon.
  /// Returns a generic money icon for unknown categories.
  /// 
  /// Example: `icon("Food")` returns `Icons.restaurant`
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

  /// Returns the color representing the given category.
  /// 
  /// Maps each category to a distinct color for visual differentiation.
  /// Returns grey for unknown categories.
  /// 
  /// Example: `color("Food")` returns `Colors.orange`
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

  /// Returns an appropriate icon for a savings goal based on its description.
  /// 
  /// Analyzes the goal description text to select a relevant icon.
  /// Returns a generic flag icon if no specific match is found.
  /// 
  /// Example: A goal with "vacation" in the description returns `Icons.beach_access`
  static IconData iconForGoal(Goal goal) {
    final desc = goal.description.toLowerCase();
    if (desc.contains('vacation')) return Icons.beach_access;
    if (desc.contains('down payment') || desc.contains('home')) {
      return Icons.home;
    }
    if (desc.contains('emergency')) return Icons.warning_amber;
    if (desc.contains('car')) return Icons.directions_car;
    return Icons.flag;
  }
}
