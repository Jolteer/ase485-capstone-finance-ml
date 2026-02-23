import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';
import 'package:ase485_capstone_finance_ml/widgets/summary_card.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
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
// Dashboard tab
// ---------------------------------------------------------------------------

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSpend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Greeting(theme: theme),
          const SizedBox(height: 20),
          const _SummaryCards(),
          const SizedBox(height: 24),
          _QuickActionsBar(theme: theme),
          const SizedBox(height: 24),
          _RecentTransactionsSection(theme: theme),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting
// ---------------------------------------------------------------------------

class _Greeting extends StatelessWidget {
  const _Greeting({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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
// Summary cards grid
// ---------------------------------------------------------------------------

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Balance',
                value: '\$4,250.00',
                icon: Icons.account_balance_wallet,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Spent',
                value: '\$1,820.50',
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Income',
                value: '\$6,070.50',
                icon: Icons.trending_up,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Savings',
                value: '\$850.00',
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
// Quick actions
// ---------------------------------------------------------------------------

class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 6),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent transactions
// ---------------------------------------------------------------------------

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 8),
        ..._recentTransactions.map((t) => TransactionTile(transaction: t)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data (uses the real Transaction model)
// ---------------------------------------------------------------------------

final _recentTransactions = [
  Transaction(
    id: '1',
    userId: 'demo',
    amount: -85.40,
    category: 'Food',
    description: 'Grocery Store',
    date: DateTime(2026, 2, 22),
  ),
  Transaction(
    id: '2',
    userId: 'demo',
    amount: -120.00,
    category: 'Bills',
    description: 'Electric Bill',
    date: DateTime(2026, 2, 20),
  ),
  Transaction(
    id: '3',
    userId: 'demo',
    amount: 3200.00,
    category: 'Other',
    description: 'Salary Deposit',
    date: DateTime(2026, 2, 15),
  ),
  Transaction(
    id: '4',
    userId: 'demo',
    amount: -15.99,
    category: 'Entertainment',
    description: 'Netflix',
    date: DateTime(2026, 2, 14),
  ),
  Transaction(
    id: '5',
    userId: 'demo',
    amount: -45.00,
    category: 'Transportation',
    description: 'Gas Station',
    date: DateTime(2026, 2, 13),
  ),
];
