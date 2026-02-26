import 'package:flutter/material.dart';

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
