import 'package:flutter/material.dart';

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
          // Monthly overview card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('February 2026', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '\$1,820 / \$3,000',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.61,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '61% of monthly budget used',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Category Budgets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Category budget items
          ..._budgetItems.map(
            (b) => _BudgetCategoryTile(
              category: b.category,
              spent: b.spent,
              limit: b.limit,
              icon: b.icon,
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

class _BudgetCategoryTile extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final IconData icon;

  const _BudgetCategoryTile({
    required this.category,
    required this.spent,
    required this.limit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (spent / limit).clamp(0.0, 1.0);
    final overBudget = spent > limit;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${spent.toStringAsFixed(0)} / \$${limit.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: overBudget
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                color: overBudget ? theme.colorScheme.error : null,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetItem {
  final String category;
  final double spent;
  final double limit;
  final IconData icon;
  const _BudgetItem(this.category, this.spent, this.limit, this.icon);
}

const _budgetItems = [
  _BudgetItem('Food', 420, 500, Icons.restaurant),
  _BudgetItem('Entertainment', 180, 200, Icons.movie),
  _BudgetItem('Bills', 650, 600, Icons.receipt_long),
  _BudgetItem('Shopping', 210, 300, Icons.shopping_bag),
  _BudgetItem('Transportation', 160, 200, Icons.directions_car),
  _BudgetItem('Healthcare', 80, 150, Icons.local_hospital),
  _BudgetItem('Education', 50, 100, Icons.school),
];
