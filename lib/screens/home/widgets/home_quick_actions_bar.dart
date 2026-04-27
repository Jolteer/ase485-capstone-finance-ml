/// Row of four shortcut tiles (Add, Analytics, Tips, Settings) on the home dashboard.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';

class HomeQuickActionsBar extends StatelessWidget {
  const HomeQuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Add',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.addTransaction),
            ),
            _QuickAction(
              icon: Icons.insights,
              label: 'Analytics',
              onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
            ),
            _QuickAction(
              icon: Icons.lightbulb_outline,
              label: 'Tips',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.recommendations),
            ),
            _QuickAction(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
