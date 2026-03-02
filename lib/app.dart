import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';

/// Root widget of the SmartSpend application.
/// 
/// Configures the MaterialApp with theme, routing, and initial settings.
/// Supports both light and dark themes based on system preferences.
class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application title shown in task switcher
      title: 'SmartSpend',
      
      // Light theme configuration
      theme: AppTheme.lightTheme,
      
      // Dark theme configuration
      darkTheme: AppTheme.darkTheme,
      
      // Follow system theme preference
      themeMode: ThemeMode.system,
      
      // Named route mappings
      routes: AppRoutes.routes,
      
      // Initial route to display on app launch
      initialRoute: AppRoutes.home,
      
      // Hide debug banner in development mode
      debugShowCheckedModeBanner: false,
    );
  }
}
