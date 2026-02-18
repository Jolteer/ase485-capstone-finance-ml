import 'package:flutter/material.dart';

/// Screen that lists all of the user’s transactions.
///
/// Planned features:
/// • A scrollable list of [TransactionTile] widgets.
/// • Filter chips / dropdown to filter by category.
/// • Date-range picker to narrow results.
///
/// The [FloatingActionButton] navigates to [AddTransactionScreen] so
/// the user can record a new transaction.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const Center(
        // TODO: Implement transaction list with category filters
        child: Text('Transactions Screen – Coming Soon'),
      ),
      // FAB to quickly add a new transaction.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add transaction screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
