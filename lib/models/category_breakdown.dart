/// Spending summary for a single category (e.g. for pie charts or breakdowns).
///
/// [ratio] is the proportion of total spending (0.0–1.0). Typically built
/// from aggregated transactions, not persisted directly.
class CategoryBreakdown {
  /// Category name (e.g. "Food", "Transport").
  final String category;

  /// Total amount spent in this category.
  final double amount;

  /// Proportion of total spending (0.0–1.0).
  final double ratio;

  const CategoryBreakdown(this.category, this.amount, this.ratio);
}
