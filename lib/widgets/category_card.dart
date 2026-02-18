import 'package:flutter/material.dart';

/// A card that visualises how much of a category budget has been used.
///
/// Shows:
/// • The category name as a title.
/// • A coloured [LinearProgressIndicator] representing [spent] / [limit].
/// • A dollar-formatted label (e.g. `$120.00 / $200.00`).
///
/// [progress] is clamped to 0–1 so the bar never overflows even if the
/// user has overspent.
class CategoryCard extends StatelessWidget {
  /// Display name of the spending category (e.g. “Food”).
  final String category;

  /// Dollar amount already spent in this category during the period.
  final double spent;

  /// The budget limit for this category.
  final double limit;

  /// Accent colour used for the progress bar.
  final Color color;

  const CategoryCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.color,
  });

  /// Ratio of [spent] to [limit], clamped between 0 and 1 to prevent
  /// the progress bar from exceeding its bounds.
  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name header.
            Text(category, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Coloured progress bar indicating budget utilisation.
            LinearProgressIndicator(value: progress, color: color),
            const SizedBox(height: 4),
            // Dollar amounts: spent vs. limit.
            Text(
              '\$${spent.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }
}
