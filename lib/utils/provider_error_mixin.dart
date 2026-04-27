/// Mixin that wires a [ChangeNotifier] provider's `error` field to a [SnackBar].
///
/// Eliminates the ~20-line `didChangeDependencies` / `addListener` /
/// `_onProviderChanged` boilerplate that was duplicated across every screen
/// that consumes a provider with an `error` / `clearError` contract.
///
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with ProviderErrorMixin {
///   @override
///   void didChangeDependencies() {
///     super.didChangeDependencies();
///     listenForErrors<BudgetProvider>(
///       context.read<BudgetProvider>(),
///       getError: (p) => p.error,
///       clearError: (p) => p.clearError(),
///     );
///   }
/// }
/// ```
library;

import 'package:flutter/material.dart';

/// Descriptor for one provider being listened to.
class _Subscription {
  final ChangeNotifier provider;
  final VoidCallback listener;

  _Subscription(this.provider, this.listener);
}

/// Mixin on [State] that auto-subscribes to one or more providers and shows a
/// [SnackBar] whenever their `error` field is non-null.
mixin ProviderErrorMixin<W extends StatefulWidget> on State<W> {
  final List<_Subscription> _errorSubscriptions = [];

  /// Subscribe to [provider]'s change notifications and show a [SnackBar]
  /// whenever [getError] returns a non-null value.
  ///
  /// Safe to call repeatedly in [didChangeDependencies]; duplicate listeners
  /// for the same provider instance are skipped.
  void listenForErrors<T extends ChangeNotifier>(
    T provider, {
    required String? Function(T) getError,
    required void Function(T) clearError,
  }) {
    final alreadyListening = _errorSubscriptions.any(
      (s) => identical(s.provider, provider),
    );
    if (alreadyListening) return;

    void listener() {
      final error = getError(provider);
      if (error != null && mounted) {
        // Clear synchronously so the next provider update doesn't re-fire this
        // listener with the same error before the SnackBar is shown.
        clearError(provider);
        // Defer the SnackBar to the next frame: showing one inside a notifier
        // callback can land mid-build and trigger "setState during build".
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        });
      }
    }

    provider.addListener(listener);
    _errorSubscriptions.add(_Subscription(provider, listener));
  }

  @override
  void dispose() {
    for (final sub in _errorSubscriptions) {
      sub.provider.removeListener(sub.listener);
    }
    _errorSubscriptions.clear();
    super.dispose();
  }
}
