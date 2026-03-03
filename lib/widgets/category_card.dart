/// Card showing one category's budget: name, spent/limit, progress bar; red when over budget.
///
/// Used on [BudgetScreen]. Optional [onTap] for edit/detail.
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// Budget category card with icon, spent/limit text, and progress bar (turns error color when over).
class CategoryCard extends StatelessWidget {
  /// Category name (e.g. "Food", "Bills").
  final String category;

  /// Amount spent in this category.
  final double spent;

  /// Budget limit for this category.
  final double limit;

  /// Icon for the category (e.g. from [Categories.icon]).
  final IconData icon;

  /// Optional tap handler (e.g. open edit).
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Progress bar value (0..1); cap at 1 so bar doesn't overflow
    final ratio = (spent / limit).clamp(0.0, 1.0);
    final overBudget = spent > limit;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    '${Formatters.currency(spent)} / ${Formatters.currency(limit)}',
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
      ),
    );
  }
}
