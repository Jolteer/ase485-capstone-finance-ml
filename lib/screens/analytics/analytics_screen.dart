import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Period selector
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Week')),
              ButtonSegment(value: 1, label: Text('Month')),
              ButtonSegment(value: 2, label: Text('Year')),
            ],
            selected: const {1},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(height: 20),

          // Spending summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Spending', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '\$1,820.50',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12% less than last month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category breakdown
          Text(
            'Spending by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ..._categoryBreakdown.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(c.name, style: theme.textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: c.ratio,
                        minHeight: 16,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: c.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '\$${c.amount.toStringAsFixed(0)}',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Monthly comparison
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Month over Month', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MonthStat(month: 'Dec', amount: '\$2,400'),
                      _MonthStat(month: 'Jan', amount: '\$2,070'),
                      _MonthStat(
                        month: 'Feb',
                        amount: '\$1,820',
                        isCurrent: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthStat extends StatelessWidget {
  final String month;
  final String amount;
  final bool isCurrent;
  const _MonthStat({
    required this.month,
    required this.amount,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          amount,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isCurrent ? theme.colorScheme.primary : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(month, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _CatBreakdown {
  final String name;
  final double amount;
  final double ratio;
  final Color color;
  const _CatBreakdown(this.name, this.amount, this.ratio, this.color);
}

const _categoryBreakdown = [
  _CatBreakdown('Food', 420, 0.84, Colors.orange),
  _CatBreakdown('Bills', 650, 1.0, Colors.red),
  _CatBreakdown('Shopping', 210, 0.42, Colors.purple),
  _CatBreakdown('Transport', 160, 0.32, Colors.blue),
  _CatBreakdown('Entertain.', 180, 0.36, Colors.teal),
  _CatBreakdown('Healthcare', 80, 0.16, Colors.pink),
  _CatBreakdown('Education', 50, 0.10, Colors.indigo),
];
