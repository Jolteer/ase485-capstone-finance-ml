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
}
