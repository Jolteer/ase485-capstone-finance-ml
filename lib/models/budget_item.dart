/// View model for one category's spending vs budget (e.g. for progress bars).
///
/// Use [ratio] for UI (0.0–1.0) and [isOverBudget] for over-limit styling.
/// Not persisted; typically built from [Budget] and transaction totals.
class BudgetItem {
  /// Category name (e.g. "Groceries").
  final String category;

  /// Amount spent in this category for the period.
  final double spent;

  /// Budget limit for this category.
  final double limit;

  const BudgetItem(this.category, this.spent, this.limit);

  /// Fraction of budget spent (0.0–1.0); 0 if limit is zero.
  double get ratio => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0;

  /// True when [spent] exceeds [limit].
  bool get isOverBudget => spent > limit;
}
