import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => ApiClient(),
          dispose: (_, client) => client.dispose(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              TransactionProvider(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => BudgetProvider(apiClient: ctx.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GoalProvider(apiClient: ctx.read<ApiClient>()),
        ),
      ],
      child: MaterialApp(
        title: 'SmartSpend',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.login,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
