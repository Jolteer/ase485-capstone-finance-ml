import 'package:flutter/material.dart';
import '../models/budget.dart';

/// Displays a single budget category with progress indicator.
class BudgetCard extends StatelessWidget {
  final Budget budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(budget.category),
        subtitle: LinearProgressIndicator(value: budget.percentUsed / 100),
        trailing: Text('\$${budget.remaining.toStringAsFixed(2)} left'),
      ),
    );
  }
}
