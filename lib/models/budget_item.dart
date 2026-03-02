/// Represents a budget line-item showing spending progress for a category.
/// 
/// Pairs a [category] with the [spent] amount versus the [limit] amount,
/// typically used for displaying budget overview summaries.
class BudgetItem {
  /// The spending category name (e.g., 'Food', 'Transport').
  final String category;
  
  /// Amount already spent in this category.
  final double spent;
  
  /// Budget limit (maximum allowed spending) for this category.
  final double limit;
  
  /// Creates a new [BudgetItem] with the given category, spent amount, and limit.
  const BudgetItem(this.category, this.spent, this.limit);
}
