import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';

/// Main dashboard — the first screen the user sees after logging in.
///
/// Uses an [IndexedStack] to preserve the state of each tab while
/// switching between them via the [BottomNavigationBar].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// The five top-level screens corresponding to each nav-bar tab.
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
      // IndexedStack keeps all children alive so state is preserved
      // when switching tabs.
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

/// The Home tab body — placeholder for the dashboard content.
class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartSpend')),
      body: const Center(
        // TODO: Add dashboard summary cards, recent transactions, budget snapshot
        child: Text('Home Screen – Coming Soon'),
      ),
    );
  }
}
