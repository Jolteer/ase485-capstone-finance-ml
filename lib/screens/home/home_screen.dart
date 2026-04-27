/// Main shell: bottom nav (Home, Transactions, Budget, Goals, Account) and dashboard tab.
///
/// Uses [IndexedStack] to keep tab state across switches (the alternative,
/// rebuilding each tab on selection, would re-fetch and lose scroll position).
/// The home tab ([HomeDashboard]) has no inner [Scaffold] so the outer
/// [HomeScreen] Scaffold owns its [AppBar]; other tabs supply their own
/// Scaffold since they are also reachable as standalone named routes.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/home/widgets/home_dashboard.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/widgets/notification_bell.dart';

/// Root screen: single Scaffold with bottom nav and an [IndexedStack] of tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeDashboard(),
    TransactionsScreen(),
    BudgetScreen(),
    GoalsScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
      context.read<BudgetProvider>().fetchBudgets();
    });
  }

  // Only the home tab uses this Scaffold's AppBar; the other tabs supply their
  // own via their inner Scaffolds.
  PreferredSizeWidget? get _appBar {
    if (_currentIndex != 0) return null;
    return AppBar(
      title: const Text('SmartSpend'),
      actions: const [NotificationBell()],
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
