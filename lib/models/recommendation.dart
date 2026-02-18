/// Data model for an ML-generated savings recommendation.
///
/// The backend’s ML pipeline analyses the user’s spending patterns and returns
/// at least [AppConstants.minRecommendations] of these per analysis.
///
/// - [id]               – unique identifier.
/// - [category]         – the spending category this tip relates to.
/// - [title]            – short headline (e.g. “Cut dining expenses”).
/// - [description]      – detailed, actionable savings advice.
/// - [potentialSavings] – estimated dollar savings if the user follows the tip.
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

  /// Deserialise a [Recommendation] from a JSON map returned by the API.
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      potentialSavings: (json['potential_savings'] as num).toDouble(),
    );
  }

  /// Serialise this [Recommendation] to a JSON map.
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
