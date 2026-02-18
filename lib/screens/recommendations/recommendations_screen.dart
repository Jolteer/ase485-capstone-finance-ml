import 'package:flutter/material.dart';

/// Screen that displays personalised, ML-generated savings tips.
///
/// The backend analyses the user’s transaction history and returns a
/// list of [Recommendation] objects. Each recommendation includes a
/// title, description, related spending category, and an estimated
/// dollar amount the user could save.
///
/// Planned features:
/// • A scrollable list of recommendation cards.
/// • Pull-to-refresh to re-run the ML analysis.
/// • Tap a recommendation to see a detailed breakdown.
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: const Center(
        // TODO: Show personalized savings recommendations list
        child: Text('Recommendations Screen – Coming Soon'),
      ),
    );
  }
}
