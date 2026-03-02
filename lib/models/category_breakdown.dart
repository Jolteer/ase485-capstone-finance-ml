/// A single category's spending data with its proportion of total spending.
///
/// Used in analytics views to visualise spending distribution.
class CategoryBreakdown {
  final String category;
  final double amount;
  final double ratio;

  const CategoryBreakdown(this.category, this.amount, this.ratio);
}
