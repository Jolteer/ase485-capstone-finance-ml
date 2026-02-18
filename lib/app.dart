import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';

/// Root widget of the SmartSpend application.
///
/// Sets up [MaterialApp] with:
/// - Light and dark themes that follow the device's system setting.
/// - A named-route table so screens can be navigated to by path string
///   (e.g. `Navigator.pushNamed(context, '/budget')`).
/// - [HomeScreen] as the default landing page.
/// - The debug banner hidden for a cleaner look during development.
class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpend',
      // Use the custom light and dark themes defined in config/theme.dart.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Automatically switch between light/dark based on OS setting.
      themeMode: ThemeMode.system,
      // Register all named routes from config/routes.dart.
      routes: AppRoutes.routes,
      // The '/' route in AppRoutes.routes serves as the initial screen.
      initialRoute: AppRoutes.home,
      debugShowCheckedModeBanner: false,
    );
  }
}
