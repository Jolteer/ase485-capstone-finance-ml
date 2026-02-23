import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/auth_service.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';

/// Root widget — sets up providers, theming, and routing.
class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared HTTP client used by all services
    final apiClient = ApiClient();

    // Wrap the app in MultiProvider so every screen can access state
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(TransactionService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(BudgetService(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(GoalService(apiClient)),
        ),
      ],
      child: MaterialApp(
        title: 'SmartSpend',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.home,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
