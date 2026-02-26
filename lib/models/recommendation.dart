/// An ML-generated spending recommendation with estimated [potentialSavings].
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

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      potentialSavings: (json['potential_savings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'potential_savings': potentialSavings,
    };
  }

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
