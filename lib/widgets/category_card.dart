import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/utils/utils.dart';

/// Card widget showing budget progress for a spending category.
/// 
/// Displays category name, icon, spending amounts, and a progress bar.
/// The card shows an error state (red) if spending exceeds the budget limit.
class CategoryCard extends StatelessWidget {
  /// The spending category name (e.g., "Food", "Transportation").
  final String category;
  
  /// Amount already spent in this category.
  final double spent;
  
  /// Budget limit for this category.
  final double limit;
  
  /// Icon representing this category.
  final IconData icon;
  
  /// Optional callback when the card is tapped.
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
