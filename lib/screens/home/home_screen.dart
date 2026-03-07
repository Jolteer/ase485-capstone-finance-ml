/// Main shell: bottom nav (Home, Transactions, Budget, Goals, Account) and dashboard tab.
///
/// Uses [IndexedStack] to keep tab state. The home tab ([_HomeDashboard]) is a plain
/// widget — no inner [Scaffold] — so the outer [HomeScreen] Scaffold is the only one
/// for that tab, eliminating the double-Scaffold anti-pattern.
/// Other tabs have their own Scaffolds, which is acceptable because they are also
/// standalone named routes.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/constants.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';
import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';
import 'package:ase485_capstone_finance_ml/widgets/summary_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

/// Root screen: single Scaffold with bottom nav and an [IndexedStack] of tabs.
///
/// The home tab uses this Scaffold's [AppBar]; all other tabs supply their own
/// via their inner Scaffolds.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    _HomeDashboard(),
    TransactionsScreen(),
    BudgetScreen(),
    GoalsScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-load transactions so the home dashboard has real data immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  /// AppBar shown only for the home tab; other tabs render their own.
  PreferredSizeWidget? get _appBar {
    if (_currentIndex != 0) return null;
    return AppBar(
      title: const Text('SmartSpend'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {}, // TODO: notifications
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HomeDashboard — no Scaffold; lives inside the HomeScreen Scaffold
// ---------------------------------------------------------------------------

/// Dashboard body: greeting, summary cards, quick actions, recent transactions.
///
/// Intentionally not a [Scaffold]; the outer [HomeScreen] Scaffold provides the
/// [AppBar] and [BottomNavigationBar] for this tab.
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TransactionProvider>().isLoading;
    return LoadingOverlay(
      isLoading: isLoading,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _Greeting(),
          SizedBox(height: AppSpacing.s20),
          _SummaryCards(),
          SizedBox(height: AppSpacing.lg),
          _QuickActionsBar(),
          SizedBox(height: AppSpacing.lg),
          _RecentTransactionsSection(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _Greeting
// ---------------------------------------------------------------------------

/// "Welcome back, `name`!" greeting that reads the real user name from [AuthProvider].
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = context.watch<AuthProvider>().currentUser?.name;
    final headline = name != null ? 'Welcome back, $name!' : 'Welcome back!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Here\'s your financial overview',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _SummaryCards
// ---------------------------------------------------------------------------

/// 2×2 grid of [SummaryCard]s computed from the current month's transactions.
///
/// - **Income**: sum of positive amounts in the current calendar month.
/// - **Spent**: sum of absolute expense amounts in the current calendar month.
/// - **Balance**: income − spent (can be negative if overspent).
/// - **Savings**: balance clamped to zero (never shown as negative).
class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final now = DateTime.now();

    final monthly = transactions.where(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );

    final income = monthly
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final spent = monthly
        .where((t) => t.isExpense)
        .fold(0.0, (s, t) => s + t.absAmount);
    final balance = income - spent;
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

// ---------------------------------------------------------------------------
// _QuickActionsBar  (unchanged logic; kept here for clarity)
// ---------------------------------------------------------------------------

/// Row of quick actions: Add, Analytics, Tips, Settings.
class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Add',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.addTransaction),
            ),
            _QuickAction(
              icon: Icons.insights,
              label: 'Analytics',
              onTap: () => Navigator.pushNamed(context, AppRoutes.analytics),
            ),
            _QuickAction(
              icon: Icons.lightbulb_outline,
              label: 'Tips',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.recommendations),
            ),
            _QuickAction(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
      ],
    );
  }
}

/// Single quick-action button: icon inside a [CircleAvatar] with label below.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _RecentTransactionsSection
// ---------------------------------------------------------------------------

/// "Recent Transactions" section: header with "See all" link and up to 5
/// [TransactionTile]s from [TransactionProvider]; each tile taps through to
/// the edit screen.
class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = context
        .watch<TransactionProvider>()
        .transactions
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.transactions),
              child: const Text('See all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Text(
                'No transactions yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...recent.map(
            (t) => TransactionTile(
              transaction: t,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
                arguments: t,
              ),
            ),
          ),
      ],
    );
  }
}
