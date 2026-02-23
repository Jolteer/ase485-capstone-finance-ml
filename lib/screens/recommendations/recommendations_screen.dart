import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InsightsBanner(),
          const SizedBox(height: 16),
          ..._sampleRecommendations.map(
            (r) => _RecommendationTile(recommendation: r),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI-Powered Insights banner
// ---------------------------------------------------------------------------

class _InsightsBanner extends StatelessWidget {
  const _InsightsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 32,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-Powered Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on your spending patterns, here are ways to save.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recommendation tile
// ---------------------------------------------------------------------------

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final color = Categories.color(recommendation.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(Categories.icon(recommendation.category), color: color),
        ),
        title: Text(
          recommendation.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(recommendation.description),
        trailing: Text(
          'Save ${Formatters.currency(recommendation.potentialSavings)}',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data (uses the real Recommendation model)
// ---------------------------------------------------------------------------

const _sampleRecommendations = [
  Recommendation(
    id: '1',
    category: 'Food',
    title: 'Reduce dining out',
    description:
        'You spent 30% more on restaurants this month compared to your average.',
    potentialSavings: 85,
  ),
  Recommendation(
    id: '2',
    category: 'Entertainment',
    title: 'Review subscriptions',
    description:
        'You have 3 subscriptions totaling \$45/mo. Consider canceling unused ones.',
    potentialSavings: 15,
  ),
  Recommendation(
    id: '3',
    category: 'Bills',
    title: 'Lower utility costs',
    description:
        'Your electric bill is higher than similar households. Try off-peak usage.',
    potentialSavings: 30,
  ),
  Recommendation(
    id: '4',
    category: 'Shopping',
    title: 'Set a shopping limit',
    description:
        'Impulse purchases added up to \$120 this month. A weekly cap could help.',
    potentialSavings: 60,
  ),
  Recommendation(
    id: '5',
    category: 'Transportation',
    title: 'Optimize commute',
    description: 'Carpooling or public transit 2 days/week could save on gas.',
    potentialSavings: 40,
  ),
];
