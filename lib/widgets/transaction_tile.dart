/// List tile for one [Transaction]: category icon, description, category + date, amount (red/green by sign).
///
/// Used on [TransactionsScreen] and home dashboard recent list. Optional [onTap] for detail/edit.
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// [ListTile] showing transaction description, category, date, and amount (expense = error color, income = green).
class TransactionTile extends StatelessWidget {
  /// The transaction to display.
  final Transaction transaction;

  /// Optional tap handler (e.g. edit or delete).
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  /// True when amount is negative (expense); used for trailing text color.
  bool get _isExpense => transaction.amount < 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = Categories.icon(transaction.category);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        '${transaction.category}  ·  ${Formatters.date(transaction.date)}',
      ),
      trailing: Text(
        Formatters.currency(transaction.amount),
        style: theme.textTheme.titleSmall?.copyWith(
          color: _isExpense ? theme.colorScheme.error : AppColors.income,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
