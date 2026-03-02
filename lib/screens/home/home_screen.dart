import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/widgets/widgets.dart';

/// Main home screen with bottom navigation bar.
/// 
/// Provides a tabbed interface with five main sections: Dashboard,
/// Transactions, Budget, Goals, and Account. Uses [IndexedStack]
/// to preserve state when switching between tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for the [HomeScreen].
class _HomeScreenState extends State<HomeScreen> {
  /// Currently selected bottom navigation index.
  int _currentIndex = 0;

  /// List of screens corresponding to each bottom navigation tab.
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

/// Dashboard tab showing financial overview.
/// 
/// Displays greeting, summary cards (balance, spent, income, savings),
/// quick action buttons, and recent transactions list.
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSpend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {}, // TODO: implement notifications
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Greeting(),
          const SizedBox(height: 20),
          const _SummaryCards(),
          const SizedBox(height: 24),
          const _QuickActionsBar(),
          const SizedBox(height: 24),
          const _RecentTransactionsSection(),
        ],
      ),
    );
  }
}

/// Greeting widget displaying welcome message.
/// 
/// Shows a personalized welcome message and subtitle to the user.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

/// Grid of financial summary cards.
/// 
/// Displays four key financial metrics in a 2x2 grid:
/// Balance, Spent, Income, and Savings.
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

/// Quick action buttons for common tasks.
/// 
/// Provides shortcuts to frequently used features: Add Transaction,
/// Analytics, Tips (Recommendations), and Settings.
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

/// Individual quick action button.
/// 
/// Displays an icon, label, and handles tap events for navigation.
class _QuickAction extends StatelessWidget {
  /// Icon to display in the action button.
  final IconData icon;
  
  /// Label text displayed below the icon.
  final String label;
  
  /// Callback function when the action is tapped.
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

/// Recent transactions section.
/// 
/// Displays a list of the most recent transactions with a "See all" link
/// to navigate to the full transactions screen.
class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        ...recentTransactions.map((t) => TransactionTile(transaction: t)),
      ],
    );
  }
}
