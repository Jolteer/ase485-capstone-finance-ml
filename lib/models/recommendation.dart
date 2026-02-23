/// An ML-generated savings recommendation for the user.
class Recommendation {
  final String id;
  final String category;
  final String title;
  final String description;
  final double potentialSavings;

  const Recommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.potentialSavings,
  });

  /// Deserialize from JSON (snake_case keys from the API).
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      potentialSavings: (json['potential_savings'] as num).toDouble(),
    );
  }

  /// Serialize to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'potential_savings': potentialSavings,
    };
  }

  /// Create a copy with selectively overridden fields.
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
}
