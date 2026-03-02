/// A budget line-item pairing a [category] with [spent] vs [limit] amounts.
class BudgetItem {
  final String category;
  final double spent;
  final double limit;
  const BudgetItem(this.category, this.spent, this.limit);
}
