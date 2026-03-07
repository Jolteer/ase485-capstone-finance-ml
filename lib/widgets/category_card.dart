/// Card showing one category's budget: name, spent/limit, progress bar; red when over budget.
///
/// Used on [BudgetScreen]. Optional [onTap] for edit/detail.
/// When [icon] is omitted, defaults to the [TransactionCategoryUi] icon for [category].
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// Budget category card with icon, spent/limit text, and progress bar (turns error color when over).
class CategoryCard extends StatelessWidget {
  /// Category this card represents.
  final TransactionCategory category;

  /// Amount spent in this category.
  final double spent;

  /// Budget limit for this category.
  final double limit;

  /// Icon for the category; defaults to the [TransactionCategoryUi] icon for [category].
  final IconData icon;

  /// Optional tap handler (e.g. open edit).
  final VoidCallback? onTap;

  CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    IconData? icon,
    this.onTap,
  }) : icon = icon ?? category.icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Guard against limit == 0 to prevent division-by-zero.
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final overBudget = limit > 0 && spent > limit;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    category.label,
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
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: AppSpacing.sm,
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
