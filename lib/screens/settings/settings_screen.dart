/// App settings: appearance (dark mode), notifications, security (biometric),
/// data (export CSV / clear), about, and logout.
///
/// All toggles are backed by [SettingsProvider] which persists values to
/// [SharedPreferences]. Dark-mode changes are reflected immediately app-wide
/// because [app.dart] watches [SettingsProvider.themeMode].
///
/// CSV export builds a comma-separated document from the in-memory transaction
/// list and copies it to the system clipboard (cross-platform, no extra plugin).
/// "Clear data" presents a confirmation dialog, wipes settings via
/// [SettingsProvider.clearSettings], and logs the user out.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/settings_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// Settings screen with grouped options and logout at bottom.
///
/// Converted to [StatelessWidget] — all mutable state lives in [SettingsProvider].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ── CSV export ─────────────────────────────────────────────────────────────

  /// Serialises the current transaction list to CSV and copies it to clipboard.
  ///
  /// Header row: `date,description,category,amount`
  /// Amount sign convention: negative = expense, positive = income.
  String _buildCsv(List<Transaction> transactions) {
    final buf = StringBuffer('date,description,category,amount\n');
    for (final t in transactions) {
      final date = Formatters.date(t.date);
      final desc = t.description.contains(',')
          ? '"${t.description}"'
          : t.description;
      final cat = t.category.label;
      final amount = t.amount.toStringAsFixed(2);
      buf.writeln('$date,$desc,$cat,$amount');
    }
    return buf.toString();
  }

  Future<void> _exportCsv(BuildContext context) async {
    final transactions = context.read<TransactionProvider>().transactions;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export.')),
      );
      return;
    }

    final csv = _buildCsv(transactions);
    await Clipboard.setData(ClipboardData(text: csv));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CSV copied to clipboard (${transactions.length} transactions).',
        ),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  // ── Clear data ─────────────────────────────────────────────────────────────

  Future<void> _confirmAndClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will erase all local settings and log you out. '
          'Transactions and budgets stored on the server are unaffected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<SettingsProvider>().clearSettings();
    if (!context.mounted) return;

    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),

          // ── Appearance ───────────────────────────────────────────────────
          const _SectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: settings.darkMode,
            onChanged: context.read<SettingsProvider>().setDarkMode,
          ),
          const Divider(),

          // ── Notifications ────────────────────────────────────────────────
          const _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Push Notifications'),
            subtitle: const Text('Budget alerts & reminders'),
            value: settings.notifications,
            onChanged: context.read<SettingsProvider>().setNotifications,
          ),
          const Divider(),

          // ── Security ─────────────────────────────────────────────────────
          const _SectionHeader('Security'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint or face ID'),
            value: settings.biometric,
            onChanged: context.read<SettingsProvider>().setBiometric,
          ),
          const Divider(),

          // ── Currency / Locale ─────────────────────────────────────────────
          const _SectionHeader('Currency'),
          _LocaleTile(
            current: settings.currencyLocale,
            onChanged: context.read<SettingsProvider>().setCurrencyLocale,
          ),
          const Divider(),

          // ── Data ──────────────────────────────────────────────────────────
          const _SectionHeader('Data'),
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

          // ── About ─────────────────────────────────────────────────────────
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),

          // ── Logout ────────────────────────────────────────────────────────
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

// ── Supporting widgets ───────────────────────────────────────────────────────

/// Section label (e.g. "Appearance", "Notifications") for the settings list.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
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

/// A [ListTile] that lets the user pick a currency locale from a short list.
///
/// Tapping opens a bottom sheet with the available options. Add more entries
/// to [_locales] to extend support without touching the settings screen logic.
class _LocaleTile extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _LocaleTile({required this.current, required this.onChanged});

  static const _locales = <(String, String)>[
    ('en_US', 'USD — US Dollar (\$)'),
    ('en_GB', 'GBP — British Pound (£)'),
    ('de_DE', 'EUR — Euro (€)'),
    ('ja_JP', 'JPY — Japanese Yen (¥)'),
    ('en_IN', 'INR — Indian Rupee (₹)'),
    ('zh_CN', 'CNY — Chinese Yuan (¥)'),
  ];

  String get _label => _locales
      .firstWhere((e) => e.$1 == current, orElse: () => (current, current))
      .$2;

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) onChanged(v);
            Navigator.pop(ctx);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select Currency',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const Divider(),
              for (final (locale, label) in _locales)
                RadioListTile<String>(title: Text(label), value: locale),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: const Text('Currency'),
      subtitle: Text(_label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPicker(context),
    );
  }
}
