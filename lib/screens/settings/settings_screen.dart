import 'package:flutter/material.dart';

/// Settings screen for app configuration.
/// 
/// Provides options for appearance (dark mode), notifications,
/// security (biometric login), data management, and logout.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// State for the [SettingsScreen].
class _SettingsScreenState extends State<SettingsScreen> {
  /// Whether dark mode is enabled.
  bool _darkMode = false;
  
  /// Whether push notifications are enabled.
  bool _notifications = true;
  
  /// Whether biometric authentication is enabled.
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
            onTap: () {}, // TODO: implement CSV export
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Data'),
            subtitle: const Text('Remove all local data'),
            onTap: () {}, // TODO: implement clear data with confirmation
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
            onTap: () {}, // TODO: implement logout via AuthProvider
          ),
        ],
      ),
    );
  }
}

/// Section header for grouping related settings.
/// 
/// Displays a styled label to separate different settings categories.
class _SectionHeader extends StatelessWidget {
  /// The header title text.
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
