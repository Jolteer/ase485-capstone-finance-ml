/// List tile for one [Transaction]: category icon, description, category label + date, amount (red/green by sign).
///
/// Used on [TransactionsScreen] and home dashboard recent list. Optional [onTap] for detail/edit.
library;

import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// [ListTile] showing transaction description, category label, date, and amount
/// (expense = error color, income = green).
class TransactionTile extends StatelessWidget {
  /// The transaction to display.
  final Transaction transaction;

  /// Optional tap handler (e.g. edit or delete).
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          transaction.category.icon,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        '${transaction.category.label}  \u00B7  ${Formatters.date(transaction.date)}',
      ),
      trailing: Text(
        Formatters.currency(transaction.amount),
        style: theme.textTheme.titleSmall?.copyWith(
          color: transaction.isExpense
              ? theme.colorScheme.error
              : AppColors.income,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
