/// Confirmation dialogs shared by the Settings screen (logout, clear data).
///
/// Each helper returns ``true`` when the user accepted the destructive action,
/// ``false`` otherwise. The caller is responsible for performing the side
/// effects (logging out, wiping settings) only after a positive result.
library;

import 'package:flutter/material.dart';

class SettingsDialogs {
  SettingsDialogs._();

  /// Asks the user to confirm a logout. Returns ``true`` when they confirm.
  static Future<bool> confirmLogout(BuildContext context) async {
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
    return confirmed == true;
  }

  /// Asks the user to confirm wiping local settings + signing out.
  ///
  /// Server-side data is unaffected; the dialog wording makes that clear so
  /// a worried user doesn't expect their transactions to be deleted too.
  static Future<bool> confirmClearLocalData(BuildContext context) async {
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
    return confirmed == true;
  }
}
