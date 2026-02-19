import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final Color color;

  const CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(category),
      ),
    );
  }
}
