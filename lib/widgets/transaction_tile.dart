import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/colors.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

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
