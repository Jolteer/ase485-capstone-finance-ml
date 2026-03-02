/// A single category's spending [amount] and its [ratio] relative to the
/// highest-spending category (used for analytics bar charts).
class CategoryBreakdown {
  final String category;
  final double amount;
  final double ratio;
  const CategoryBreakdown(this.category, this.amount, this.ratio);
}
