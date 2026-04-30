/// App settings: appearance (dark mode), notifications, security (biometric),
/// data (export CSV / clear), about, and logout.
///
/// All toggles are backed by [SettingsProvider] which persists values to
/// [SharedPreferences]. Dark-mode changes are reflected immediately app-wide
/// because [app.dart] watches [SettingsProvider.themeMode].
///
/// CSV export and the destructive confirm dialogs live in helper widgets so
/// this screen reads as a flat list of sections.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/settings_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/settings/widgets/locale_picker_tile.dart';
import 'package:ase485_capstone_finance_ml/screens/settings/widgets/settings_dialogs.dart';
import 'package:ase485_capstone_finance_ml/screens/settings/widgets/settings_section_header.dart';
import 'package:ase485_capstone_finance_ml/screens/settings/widgets/transaction_csv_exporter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportCsv(BuildContext context) {
    return TransactionCsvExporter.copyToClipboard(
      context,
      context.read<TransactionProvider>().transactions,
    );
  }

  Future<void> _confirmAndClearData(BuildContext context) async {
    final confirmed = await SettingsDialogs.confirmClearLocalData(context);
    if (!confirmed || !context.mounted) return;

    await context.read<SettingsProvider>().clearSettings();
    if (!context.mounted) return;

    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await SettingsDialogs.confirmLogout(context);
    if (!confirmed || !context.mounted) return;

    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const SettingsSectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.darkMode,
            onChanged: context.read<SettingsProvider>().setDarkMode,
          ),
          const Divider(),
          const SettingsSectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Push Notifications'),
            subtitle: const Text('Budget alerts & reminders'),
            value: settings.notifications,
            onChanged: context.read<SettingsProvider>().setNotifications,
          ),
          const Divider(),
          const SettingsSectionHeader('Security'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: settings.biometric,
            onChanged: context.read<SettingsProvider>().setBiometric,
          ),
          const Divider(),
          const SettingsSectionHeader('Currency'),
          LocalePickerTile(
            current: settings.currencyLocale,
            onChanged: context.read<SettingsProvider>().setCurrencyLocale,
          ),
          const Divider(),
          const SettingsSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Transactions'),
            subtitle: const Text('Copy CSV to clipboard'),
            onTap: () => _exportCsv(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Clear Data',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Erase local settings and log out'),
            onTap: () => _confirmAndClearData(context),
          ),
          const Divider(),
          const SettingsSectionHeader('About'),
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
            onTap: () => _confirmAndLogout(context),
          ),
        ],
      ),
    );
  }
}
