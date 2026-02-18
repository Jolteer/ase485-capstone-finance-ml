import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/screens/auth/login_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/auth/register_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/home/home_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/add_transaction_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/analytics/analytics_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/recommendations/recommendations_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/settings/settings_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';

/// Defines every named route in the application.
///
/// Route strings are stored as `static const` so they can be referenced
/// type-safely throughout the codebase:
/// ```dart
/// Navigator.pushNamed(context, AppRoutes.budget);
/// ```
///
/// The [routes] getter returns the map consumed by [MaterialApp.routes].
/// Each entry maps a path string to a builder that creates the matching
/// screen widget.
class AppRoutes {
  AppRoutes._();

  // ── Route path constants ──────────────────────────────────────────────
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/add';
  static const String budget = '/budget';
  static const String goals = '/goals';
  static const String analytics = '/analytics';
  static const String recommendations = '/recommendations';
  static const String settings = '/settings';
  static const String account = '/account';

  /// Builds the route table consumed by [MaterialApp.routes].
  /// Each key is a path string and each value is a [WidgetBuilder] that
  /// returns the corresponding screen widget.
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    transactions: (_) => const TransactionsScreen(),
    addTransaction: (_) => const AddTransactionScreen(),
    budget: (_) => const BudgetScreen(),
    goals: (_) => const GoalsScreen(),
    analytics: (_) => const AnalyticsScreen(),
    recommendations: (_) => const RecommendationsScreen(),
    settings: (_) => const SettingsScreen(),
    account: (_) => const AccountScreen(),
  };
}
