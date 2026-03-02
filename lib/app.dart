import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) =>
                    TransactionProvider(apiClient: authProvider.apiClient),
              ),
              ChangeNotifierProvider(
                create: (_) =>
                    BudgetProvider(apiClient: authProvider.apiClient),
              ),
              ChangeNotifierProvider(
                create: (_) => GoalProvider(apiClient: authProvider.apiClient),
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
        },
      ),
    );
  }
}
