/// Account tab: profile header (avatar, name, email, edit) and menu (Analytics, Recommendations, Settings, Logout).
///
/// Profile data is sourced from [AuthProvider.currentUser]. Logout clears the
/// session via [AuthProvider.logout] and navigates to [AppRoutes.login].
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';

/// Account screen with profile header and navigation to analytics, recommendations, settings.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.select<AuthProvider, User?>(
      (auth) => auth.currentUser,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.lg),
          _ProfileHeader(name: user?.name ?? '', email: user?.email ?? ''),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          ..._menuItems.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, item.route),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

/// Avatar, name, email, and "Edit Profile" button.
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () {}, // TODO: edit profile
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

/// One account menu entry: icon, label, and route to push.
class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem(this.icon, this.label, this.route);
}

/// Account tab menu items (Analytics, Recommendations, Settings).
const _menuItems = [
  _MenuItem(Icons.analytics_outlined, 'Analytics', AppRoutes.analytics),
  _MenuItem(
    Icons.lightbulb_outline,
    'Recommendations',
    AppRoutes.recommendations,
  ),
  _MenuItem(Icons.settings_outlined, 'Settings', AppRoutes.settings),
];
