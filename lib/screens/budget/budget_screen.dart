import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ), // TODO: implement budget edit
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _MonthlyOverviewCard(),
          const SizedBox(height: 16),
          Text(
            'Category Budgets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sampleBudgetItems.map(
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
        onPressed: () {}, // TODO: implement add budget category
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly overview
// ---------------------------------------------------------------------------

class _MonthlyOverviewCard extends StatelessWidget {
  const _MonthlyOverviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
