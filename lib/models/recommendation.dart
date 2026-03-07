/// A savings or spending recommendation with estimated impact.
///
/// Supports JSON via [fromJson] / [toJson] and [copyWith]. Used by the
/// recommendations screen to show actionable tips and [potentialSavings].
library;
class Recommendation {
  /// Unique identifier for this recommendation.
  final String id;

  /// Category this recommendation applies to (e.g. "Food", "Subscriptions").
  final String category;

  /// Short title or summary for the recommendation.
  final String title;

  /// Detailed description or steps.
  final String description;

  /// Estimated amount the user could save by following the recommendation.
  final double potentialSavings;

  const Recommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.potentialSavings,
  });

  /// Creates a [Recommendation] from a JSON map (e.g. API response).
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      potentialSavings: (json['potential_savings'] as num).toDouble(),
    );
  }

  /// Converts this recommendation to a JSON map (snake_case keys for API).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'potential_savings': potentialSavings,
    };
  }

  /// Returns a copy of this recommendation with the given fields replaced.
  Recommendation copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    double? potentialSavings,
  }) {
    return Recommendation(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      potentialSavings: potentialSavings ?? this.potentialSavings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recommendation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          category == other.category &&
          title == other.title &&
          description == other.description &&
          potentialSavings == other.potentialSavings;

  @override
  int get hashCode =>
      Object.hash(id, category, title, description, potentialSavings);

  @override
  String toString() =>
      'Recommendation(id: $id, title: $title, savings: $potentialSavings)';
}
