import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';
import 'package:ase485_capstone_finance_ml/widgets/summary_card.dart';

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
          // Greeting
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
          const SizedBox(height: 20),

          // Summary cards row
          const Row(
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
          const SizedBox(height: 12),
          const Row(
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
          const SizedBox(height: 24),

          // Quick actions
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
          const SizedBox(height: 24),

          // Recent transactions header
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

          // Placeholder recent transactions
          ..._sampleTransactions.map(
            (t) => ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  t.icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(t.title),
              subtitle: Text(t.date),
              trailing: Text(
                t.amount,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: t.isExpense ? theme.colorScheme.error : Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
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

class _SampleTx {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final bool isExpense;
  const _SampleTx(
    this.icon,
    this.title,
    this.date,
    this.amount,
    this.isExpense,
  );
}

const _sampleTransactions = [
  _SampleTx(
    Icons.restaurant,
    'Grocery Store',
    'Feb 22, 2026',
    '-\$85.40',
    true,
  ),
  _SampleTx(
    Icons.electric_bolt,
    'Electric Bill',
    'Feb 20, 2026',
    '-\$120.00',
    true,
  ),
  _SampleTx(Icons.work, 'Salary Deposit', 'Feb 15, 2026', '+\$3,200.00', false),
  _SampleTx(Icons.movie, 'Netflix', 'Feb 14, 2026', '-\$15.99', true),
  _SampleTx(
    Icons.directions_car,
    'Gas Station',
    'Feb 13, 2026',
    '-\$45.00',
    true,
  ),
];
