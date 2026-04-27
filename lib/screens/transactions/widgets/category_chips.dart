/// Horizontal row of filter chips: "All" plus one per [TransactionCategory].
///
/// Tapping the already-selected category deselects it (falls back to "All").
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

class CategoryChips extends StatelessWidget {
  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory?> onSelected;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...TransactionCategory.values.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: FilterChip(
                label: Text(c.label),
                selected: selected == c,
                onSelected: (_) => onSelected(selected == c ? null : c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
