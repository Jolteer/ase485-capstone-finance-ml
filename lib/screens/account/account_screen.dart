/// Account tab: profile header (avatar, name, email, edit) and menu (Analytics, Recommendations, Settings, Logout).
///
/// Profile data is placeholder; edit and logout are TODO (wire to [AuthProvider]).
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';

/// Account screen with profile header and navigation to analytics, recommendations, settings.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const _ProfileHeader(),
          const SizedBox(height: 16),
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
            onTap: () {}, // TODO: logout via AuthProvider
          ),
        ],
      ),
    );
  }
}

/// Avatar, name, email, and "Edit Profile" button (placeholder data).
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
        const SizedBox(height: 12),
        Text(
          'User Name',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'user@example.com',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
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
