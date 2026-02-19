import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpend',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
