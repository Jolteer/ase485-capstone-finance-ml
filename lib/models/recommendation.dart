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
}
