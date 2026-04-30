/// Floating action button that triggers ML budget regeneration after a confirm dialog.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';

class GenerateBudgetsFab extends StatelessWidget {
  const GenerateBudgetsFab({super.key});

  Future<void> _confirmAndGenerate(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Budgets'),
        content: const Text(
          'This will analyse your spending history and replace '
          'your current budgets with ML-generated suggestions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<BudgetProvider>().generateBudgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'budget_generate_fab',
      onPressed: () => _confirmAndGenerate(context),
      child: const Icon(Icons.auto_awesome),
    );
  }
}
