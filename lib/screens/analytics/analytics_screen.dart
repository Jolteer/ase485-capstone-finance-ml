import 'package:flutter/material.dart';

/// Screen that visualises the user’s spending data with charts.
///
/// Planned features:
/// • Pie/donut chart breaking down spending by category.
/// • Bar chart comparing spending across time periods.
/// • Line chart showing spending trends over weeks/months.
/// • Period selector (weekly, monthly, yearly).
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(
        // TODO: Add spending breakdown charts (by category, by period)
        child: Text('Analytics Screen – Coming Soon'),
      ),
    );
  }
}
