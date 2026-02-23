import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/widgets/category_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MonthlyOverviewCard(theme: theme),
          const SizedBox(height: 16),
          Text(
            'Category Budgets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._budgetItems.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CategoryCard(
                category: b.category,
                spent: b.spent,
                limit: b.limit,
                icon: Categories.icon(b.category),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly overview
// ---------------------------------------------------------------------------

class _MonthlyOverviewCard extends StatelessWidget {
  const _MonthlyOverviewCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    const spent = 1820.0;
    const budget = 3000.0;
    const ratio = spent / budget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('February 2026', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${Formatters.currency(spent)} / ${Formatters.currency(budget)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}% of monthly budget used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

class _BudgetItem {
  final String category;
  final double spent;
  final double limit;
  const _BudgetItem(this.category, this.spent, this.limit);
}

const _budgetItems = [
  _BudgetItem('Food', 420, 500),
  _BudgetItem('Entertainment', 180, 200),
  _BudgetItem('Bills', 650, 600),
  _BudgetItem('Shopping', 210, 300),
  _BudgetItem('Transportation', 160, 200),
  _BudgetItem('Healthcare', 80, 150),
  _BudgetItem('Education', 50, 100),
];
