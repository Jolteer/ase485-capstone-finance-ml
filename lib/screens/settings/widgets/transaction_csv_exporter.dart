/// CSV-export helper for the Settings screen.
///
/// Builds a comma-separated document from the in-memory transaction list and
/// copies it to the system clipboard (cross-platform, no extra plugin needed).
/// Pulled out of the Settings screen so the serialisation logic is testable
/// in isolation.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class TransactionCsvExporter {
  TransactionCsvExporter._();

  /// Serialises [transactions] into a CSV string.
  ///
  /// Header: ``date,description,category,amount``. Negative amounts are
  /// expenses, positive are income (matching the rest of the app). Descriptions
  /// containing commas are quoted so the CSV stays well-formed.
  static String build(List<Transaction> transactions) {
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

  /// Builds the CSV, copies it to the clipboard, and shows a SnackBar.
  ///
  /// No-op (with informative SnackBar) when [transactions] is empty.
  static Future<void> copyToClipboard(
    BuildContext context,
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export.')),
      );
      return;
    }

    final csv = build(transactions);
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
}
