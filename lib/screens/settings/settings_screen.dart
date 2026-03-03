/// App settings: appearance (dark mode), notifications, security (biometric), data (export/clear), about, logout.
///
/// Toggles are local state; logout/export/clear are TODO (wire to [AuthProvider] and data layer).
import 'package:flutter/material.dart';

/// Settings screen with grouped options and logout at bottom.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// User preference for dark theme (not yet persisted).
  bool _darkMode = false;

  /// Push notifications enabled (not yet persisted).
  bool _notifications = true;

  /// Biometric login enabled (not yet wired to auth).
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          const _SectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          const Divider(),
          const _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Push Notifications'),
            subtitle: const Text('Budget alerts & reminders'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          const Divider(),
          const _SectionHeader('Security'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          const Divider(),
          const _SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download transactions as CSV'),
            onTap: () {}, // TODO: CSV export
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Data'),
            subtitle: const Text('Remove all local data'),
            onTap: () {}, // TODO: clear data with confirmation
          ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
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

/// Section label (e.g. "Appearance", "Notifications") for settings list.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
