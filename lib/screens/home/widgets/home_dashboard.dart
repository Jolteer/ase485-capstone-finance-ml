/// Main "Home" tab content: greeting, alerts, summary cards, quick actions, recent transactions.
///
/// Has no [Scaffold] of its own; the surrounding [HomeScreen] supplies one
/// (avoids the double-Scaffold anti-pattern when nested inside the bottom nav).
///
/// Subscribes to [TransactionProvider] errors via [ProviderErrorMixin] so a
/// failed initial fetch surfaces a SnackBar instead of failing silently.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_greeting.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_quick_actions_bar.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_recent_transactions_section.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_summary_cards.dart';
import 'package:ase485_capstone_finance_ml/utils/provider_error_mixin.dart';
import 'package:ase485_capstone_finance_ml/widgets/budget_alert_banner.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with ProviderErrorMixin<HomeDashboard> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Surface fetch failures from both providers as SnackBars; otherwise a
    // network blip during initial load would leave the dashboard empty with
    // no user-facing feedback.
    listenForErrors<TransactionProvider>(
      context.read<TransactionProvider>(),
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
    listenForErrors<BudgetProvider>(
      context.read<BudgetProvider>(),
      getError: (p) => p.error,
      clearError: (p) => p.clearError(),
    );
  }

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
