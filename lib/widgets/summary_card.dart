import 'package:flutter/material.dart';

/// Reusable card widget displaying a financial summary metric.
/// 
/// Shows an icon, title, and value in a compact card layout.
/// Commonly used for displaying key metrics like balance, income, or expenses.
class SummaryCard extends StatelessWidget {
  /// The title label for this metric (e.g., "Balance", "Income").
  final String title;
  
  /// The formatted value to display (e.g., "$4,250.00").
  final String value;
  
  /// Icon representing this metric.
  final IconData icon;
  
  /// Optional custom color for the icon. Defaults to primary color if not provided.
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
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
