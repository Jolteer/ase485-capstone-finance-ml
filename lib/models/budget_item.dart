/// A snapshot of spending against a budget limit for a single [category].
///
/// Used to display budget-vs-actual comparisons in the UI.
class BudgetItem {
  final String category;
  final double spent;
  final double limit;

  const BudgetItem(this.category, this.spent, this.limit);

  /// The spend-to-limit ratio clamped to [0, 1].
  double get ratio => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0;

  /// Whether spending has exceeded the budget limit.
  bool get isOverBudget => spent > limit;
}
