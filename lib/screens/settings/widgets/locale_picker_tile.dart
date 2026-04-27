/// A [ListTile] that lets the user pick a currency locale from a short list.
///
/// Tapping opens a bottom sheet with the available options. Add more entries
/// to [_locales] to extend support without touching the settings screen logic.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';

class LocalePickerTile extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const LocalePickerTile({
    super.key,
    required this.current,
    required this.onChanged,
  });

  static const _locales = <(String, String)>[
    ('en_US', 'USD — US Dollar (\$)'),
    ('en_GB', 'GBP — British Pound (£)'),
    ('de_DE', 'EUR — Euro (€)'),
    ('ja_JP', 'JPY — Japanese Yen (¥)'),
    ('en_IN', 'INR — Indian Rupee (₹)'),
    ('zh_CN', 'CNY — Chinese Yuan (¥)'),
  ];

  // Fallback to the raw locale code if it's not in the curated list (e.g. a
  // user-set value persisted before the list was trimmed).
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
