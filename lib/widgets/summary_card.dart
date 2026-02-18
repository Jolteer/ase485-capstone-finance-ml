import 'package:flutter/material.dart';

/// A compact card used on the home dashboard to display a single KPI.
///
/// For example: "Total Balance – $4,230.00" with a wallet icon.
///
/// Layout (vertical):
/// 1. A large icon coloured with the optional [color].
/// 2. A small label ([title]).
/// 3. A prominent value string ([value]).
class SummaryCard extends StatelessWidget {
  /// Short label displayed below the icon (e.g. “Total Balance”).
  final String title;

  /// Formatted value string (e.g. “$4,230.00”).
  final String value;

  /// Icon displayed at the top of the card.
  final IconData icon;

  /// Optional colour for the icon. Falls back to the theme default.
  final Color? color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            // Label in a smaller text style.
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            // Value in a larger, prominent text style.
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
