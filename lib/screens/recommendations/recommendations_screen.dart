import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
          ),
          const SizedBox(height: 16),
          ..._tips.map(
            (t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.color.withAlpha(40),
                  child: Icon(t.icon, color: t.color),
                ),
                title: Text(
                  t.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(t.subtitle),
                trailing: Text(
                  'Save \$${t.savings.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final double savings;
  const _Tip(this.icon, this.color, this.title, this.subtitle, this.savings);
}

const _tips = [
  _Tip(
    Icons.restaurant,
    Colors.orange,
    'Reduce dining out',
    'You spent 30% more on restaurants this month compared to your average.',
    85,
  ),
  _Tip(
    Icons.subscriptions,
    Colors.purple,
    'Review subscriptions',
    'You have 3 subscriptions totaling \$45/mo. Consider canceling unused ones.',
    15,
  ),
  _Tip(
    Icons.electric_bolt,
    Colors.amber,
    'Lower utility costs',
    'Your electric bill is higher than similar households. Try off-peak usage.',
    30,
  ),
  _Tip(
    Icons.shopping_bag,
    Colors.blue,
    'Set a shopping limit',
    'Impulse purchases added up to \$120 this month. A weekly cap could help.',
    60,
  ),
  _Tip(
    Icons.directions_car,
    Colors.teal,
    'Optimize commute',
    'Carpooling or public transit 2 days/week could save on gas.',
    40,
  ),
];
