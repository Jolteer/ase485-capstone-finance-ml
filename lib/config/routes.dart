/// Central route names and [routes] map for the app.
///
/// Use [AppRoutes] route name constants with [Navigator] (e.g. pushNamed)
/// and pass [routes] to [MaterialApp.routes] for screen resolution.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/screens/auth/login_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/auth/register_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/home/home_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/transactions_screen.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/screens/transactions/add_transaction_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/budget/budget_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/goals/goals_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/analytics/analytics_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/recommendations/recommendations_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/settings/settings_screen.dart';
import 'package:ase485_capstone_finance_ml/screens/account/account_screen.dart';

/// Defines app route path constants and the map from path to screen builder.
class AppRoutes {
  AppRoutes._();

  /// Home/dashboard route.
  static const String home = '/';

  /// Login screen route.
  static const String login = '/login';

  /// Registration screen route.
  static const String register = '/register';

  /// Transactions list route.
  static const String transactions = '/transactions';

  /// Add or edit transaction route.
  static const String addTransaction = '/transactions/add';

  /// Budget management route.
  static const String budget = '/budget';

  /// Goals management route.
  static const String goals = '/goals';

  /// Analytics dashboard route.
  static const String analytics = '/analytics';

  /// Recommendations route.
  static const String recommendations = '/recommendations';

  /// App settings route.
  static const String settings = '/settings';

  /// User account route.
  static const String account = '/account';

  /// Map of route path to [WidgetBuilder]. Pass to [MaterialApp.routes]; [initialRoute] is typically [login].
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    transactions: (_) => const TransactionsScreen(),
    addTransaction: (context) => AddTransactionScreen(
      initial: ModalRoute.of(context)?.settings.arguments as Transaction?,
    ),
    budget: (_) => const BudgetScreen(),
    goals: (_) => const GoalsScreen(),
    analytics: (_) => const AnalyticsScreen(),
    recommendations: (_) => const RecommendationsScreen(),
    settings: (_) => const SettingsScreen(),
    account: (_) => const AccountScreen(),
  };
}
