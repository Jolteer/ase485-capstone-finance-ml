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

/// Centralized route configuration for app navigation.
/// 
/// Defines all route paths and their corresponding screen widgets
/// for use with Flutter's Navigator.
class AppRoutes {
  /// Private constructor to prevent instantiation.
  AppRoutes._();

  /// Home screen route (root path).
  static const String home = '/';
  
  /// Login screen route.
  static const String login = '/login';
  
  /// Registration screen route.
  static const String register = '/register';
  
  /// Transactions list screen route.
  static const String transactions = '/transactions';
  
  /// Add transaction form screen route.
  static const String addTransaction = '/transactions/add';
  
  /// Budget management screen route.
  static const String budget = '/budget';
  
  /// Goals management screen route.
  static const String goals = '/goals';
  
  /// Analytics dashboard screen route.
  static const String analytics = '/analytics';
  
  /// Recommendations screen route.
  static const String recommendations = '/recommendations';
  
  /// Settings screen route.
  static const String settings = '/settings';
  
  /// Account management screen route.
  static const String account = '/account';

  /// Returns a map of route paths to widget builders.
  /// 
  /// Used by MaterialApp's routes parameter to define all named routes.
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
