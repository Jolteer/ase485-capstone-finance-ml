/// One row in the category breakdown: name, proportional progress bar, amount.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/category_breakdown.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key, required this.item});

  final CategoryBreakdown item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(item.category, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusXs),
              child: LinearProgressIndicator(
                value: item.ratio,
                minHeight: AppSpacing.md,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: Categories.color(item.category),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          SizedBox(
            width: 60,
            child: Text(
              Formatters.currency(item.amount),
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
