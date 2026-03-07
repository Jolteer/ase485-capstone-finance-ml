/// View model for one category's spending vs budget (e.g. for progress bars).
///
/// Use [ratio] for UI (0.0–1.0), [isOverBudget] for over-limit styling, and
/// [remainingAmount] for how much headroom is left. Not persisted; typically
/// built from [Budget] and transaction totals.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

@immutable
class BudgetItem {
  /// Category this item tracks.
  final TransactionCategory category;

  /// Amount spent in this category for the period. Must be non-negative.
  final double spent;

  /// Budget limit for this category. Must be positive.
  final double limit;

  const BudgetItem({
    required this.category,
    required this.spent,
    required this.limit,
  }) : assert(spent >= 0, 'spent must be non-negative'),
       assert(limit > 0, 'limit must be positive');

  /// Fraction of budget spent (0.0–1.0); clamped so progress indicators never overflow.
  double get ratio => (spent / limit).clamp(0.0, 1.0);

  /// True when [spent] exceeds [limit].
  bool get isOverBudget => spent > limit;

  /// Amount remaining before the limit is reached; 0 when already over budget.
  double get remainingAmount => (limit - spent).clamp(0.0, double.maxFinite);

  /// Returns a copy of this item with the given fields replaced.
  BudgetItem copyWith({
    TransactionCategory? category,
    double? spent,
    double? limit,
  }) {
    return BudgetItem(
      category: category ?? this.category,
      spent: spent ?? this.spent,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetItem &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          spent == other.spent &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(category, spent, limit);

  @override
  String toString() =>
      'BudgetItem(category: ${category.name}, spent: $spent, limit: $limit)';
}
