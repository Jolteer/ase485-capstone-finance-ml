/// Represents a generated budget for a category.
class Budget {
  final String category;
  final double limit;
  final double spent;

  Budget({required this.category, required this.limit, this.spent = 0.0});

  double get remaining => limit - spent;
  double get percentUsed => limit > 0 ? (spent / limit) * 100 : 0;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'] as String,
      limit: (json['limit'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
