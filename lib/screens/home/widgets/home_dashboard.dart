/// Main "Home" tab content: greeting, alerts, summary cards, quick actions, recent transactions.
///
/// Has no [Scaffold] of its own; the surrounding [HomeScreen] supplies one
/// (avoids the double-Scaffold anti-pattern when nested inside the bottom nav).
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_greeting.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_quick_actions_bar.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_recent_transactions_section.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_summary_cards.dart';
import 'package:ase485_capstone_finance_ml/widgets/budget_alert_banner.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TransactionProvider>().isLoading;
    return LoadingOverlay(
      isLoading: isLoading,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          HomeGreeting(),
          SizedBox(height: AppSpacing.s20),
          BudgetAlertBanner(),
          SizedBox(height: AppSpacing.sm),
          HomeSummaryCards(),
          SizedBox(height: AppSpacing.lg),
          HomeQuickActionsBar(),
          SizedBox(height: AppSpacing.lg),
          HomeRecentTransactionsSection(),
        ],
      ),
    );
  }
}
