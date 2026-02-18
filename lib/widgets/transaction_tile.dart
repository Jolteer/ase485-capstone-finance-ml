import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

/// A single row in a transaction list, implemented as a [ListTile].
///
/// Layout:
/// • Leading – a [CircleAvatar] with the first letter of the category.
/// • Title   – the transaction description.
/// • Subtitle – the category name.
/// • Trailing – the dollar amount, coloured red for expenses and green
///   for income.
///
/// An optional [onTap] callback lets the parent navigate to a detail
/// or edit view.
class TransactionTile extends StatelessWidget {
  /// The [Transaction] data to display.
  final Transaction transaction;

  /// Called when the tile is tapped (e.g. navigate to detail screen).
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      // Circle with the uppercase first letter of the category.
      leading: CircleAvatar(child: Text(transaction.category[0].toUpperCase())),
      title: Text(transaction.description),
      subtitle: Text(transaction.category),
      // Amount coloured by sign: negative = red (expense), positive = green.
      trailing: Text(
        '\$${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: transaction.amount < 0 ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
