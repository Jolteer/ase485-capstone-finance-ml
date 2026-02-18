import 'package:flutter/material.dart';

/// Screen for app-wide preferences and account management.
///
/// Current options (all are stubs awaiting implementation):
/// • **Dark Mode**      – toggle between light and dark themes.
/// • **Notifications**  – enable/disable budget alerts and goal reminders.
/// • **Logout**         – sign out and return to the login screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          // TODO: Implement settings options (theme toggle, notification prefs, logout)
          ListTile(leading: Icon(Icons.dark_mode), title: Text('Dark Mode')),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
          ),
          ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }
}
