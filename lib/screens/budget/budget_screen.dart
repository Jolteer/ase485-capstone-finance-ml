import 'package:flutter/material.dart';

/// Screen that shows the user’s ML-generated budgets, one per spending
/// category.
///
/// Planned features:
/// • A list of [CategoryCard] widgets each showing a progress bar
///   (spent vs. limit) for one category.
/// • A “Generate Budget” button that triggers the ML pipeline via
///   [BudgetProvider.generateBudget].
/// • Ability to manually adjust individual budget limits.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: const Center(
        // TODO: Show budget cards per category with progress bars
        child: Text('Budget Screen – Coming Soon'),
      ),
    );
  }
}
