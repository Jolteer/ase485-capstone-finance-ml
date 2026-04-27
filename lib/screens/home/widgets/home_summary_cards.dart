/// 2x2 grid of summary cards (Balance, Spent, Income, Savings) for the home dashboard.
///
/// Computed from the current month's transactions via [monthlyIncome] /
/// [monthlyExpenses] in `spending_helpers.dart`.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/utils/spending_helpers.dart';
import 'package:ase485_capstone_finance_ml/widgets/summary_card.dart';

class HomeSummaryCards extends StatelessWidget {
  const HomeSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;

    final income = monthlyIncome(transactions);
    final spent = monthlyExpenses(transactions);
    final balance = income - spent;
    // Savings can never be negative; treat overspending months as 0 savings.
    final savings = balance.clamp(0.0, double.maxFinite);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Balance',
                value: Formatters.currency(balance),
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: SummaryCard(
                title: 'Spent',
                value: Formatters.currency(spent),
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Income',
                value: Formatters.currency(income),
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: SummaryCard(
                title: 'Savings',
                value: Formatters.currency(savings),
                icon: Icons.savings,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
