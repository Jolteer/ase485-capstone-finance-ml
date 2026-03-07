/// Root widget: [MultiProvider] (settings, API client, auth, transaction, budget,
/// goal, recommendation providers) and [MaterialApp].
///
/// Auth guard: on startup [_AppMaterialRoot] calls [AuthProvider.tryRestore] and
/// [SettingsProvider.init] in parallel. If a valid session is found the user is
/// sent directly to [AppRoutes.home], bypassing the login screen. Any subsequent
/// logout navigates back to [AppRoutes.login] and removes all prior routes.
///
/// [ThemeMode] is derived from [SettingsProvider.themeMode] and updated
/// reactively — toggling dark mode in Settings reflects immediately everywhere.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/config/theme.dart';
import 'package:ase485_capstone_finance_ml/providers/auth_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/budget_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/goal_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/recommendation_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/settings_provider.dart';
import 'package:ase485_capstone_finance_ml/providers/transaction_provider.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Top-level app widget: providers and [MaterialApp] with routes and theme.
class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // SettingsProvider is placed first so it is available to all others
        // and to the root navigator widget for theme-mode derivation.
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        /// Singleton HTTP client; injected into auth and feature providers.
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
        ChangeNotifierProvider(
          create: (ctx) =>
              RecommendationProvider(apiClient: ctx.read<ApiClient>()),
        ),
      ],
      child: const _AppMaterialRoot(),
    );
  }
}

/// Hosts [MaterialApp] and enforces the auth guard on startup.
///
/// Calls [AuthProvider.tryRestore] and [SettingsProvider.init] concurrently
/// after the first frame. The [themeMode] is derived reactively from
/// [SettingsProvider] so toggling dark mode in Settings takes effect immediately
/// without a restart. Protected routes remain reachable only after authentication
/// because the initial route is always [AppRoutes.login].
class _AppMaterialRoot extends StatefulWidget {
  const _AppMaterialRoot();

  @override
  State<_AppMaterialRoot> createState() => _AppMaterialRootState();
}

class _AppMaterialRootState extends State<_AppMaterialRoot> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Defer until after the first frame so Provider is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialise());
  }

  /// Loads persisted settings and tries to restore an existing auth session
  /// concurrently; navigates to home if authentication is still valid.
  Future<void> _initialise() async {
    await Future.wait([
      context.read<SettingsProvider>().init(),
      context.read<AuthProvider>().tryRestore(),
    ]);
    if (!mounted) return;

    if (context.read<AuthProvider>().isAuthenticated) {
      _navigatorKey.currentState?.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch SettingsProvider so MaterialApp rebuilds when the user toggles
    // dark mode, keeping ThemeMode in sync without a restart.
    final themeMode = context.watch<SettingsProvider>().themeMode;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'SmartSpend',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.login,
      debugShowCheckedModeBanner: false,
    );
  }
}
