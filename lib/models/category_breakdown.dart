/// Represents a single category's spending analysis for visualization.
/// 
/// Contains the spending [amount] and its [ratio] relative to the
/// highest-spending category, used for analytics bar charts and comparisons.
class CategoryBreakdown {
  /// The spending category name (e.g., 'Food', 'Transport').
  final String category;
  
  /// Total amount spent in this category.
  final double amount;
  
  /// Ratio of this category's spending relative to the highest-spending category (0.0 to 1.0).
  /// Used to scale bar chart heights proportionally.
  final double ratio;
  
  /// Creates a new [CategoryBreakdown] with the given category, amount, and ratio.
  const CategoryBreakdown(this.category, this.amount, this.ratio);
}
