/// Visual shell shared by the login and register screens.
///
/// Wraps the form in a centred, scrollable [SafeArea] so both flows have the
/// same padding, scroll behaviour, and screen-size handling. Each screen
/// supplies its own `appBar`, `child` (the form), and the `LoadingOverlay`
/// flag.
library;

import 'package:flutter/material.dart';

import 'package:ase485_capstone_finance_ml/config/spacing.dart';
import 'package:ase485_capstone_finance_ml/widgets/loading_overlay.dart';

class AuthFormShell extends StatelessWidget {
  /// Optional app bar (login uses none, register shows a back button).
  final PreferredSizeWidget? appBar;

  /// True while a network request is in flight; dims the form.
  final bool isLoading;

  /// Form contents.
  final Widget child;

  const AuthFormShell({
    super.key,
    this.appBar,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
