/// Mixin that supplies the loading/error skeleton every feature provider repeats.
///
/// Provides [isLoading], [error], [clearError], plus two helpers:
/// - [runLoad] for fetch/refresh: surfaces errors but does NOT rethrow.
/// - [runMutate] for add/update/delete: surfaces errors AND rethrows so the
///   caller (UI) can react.
///
/// Both helpers `notifyListeners()` at the right moments so existing tests
/// that assert `isLoading` transitions and error population keep passing.
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

mixin AsyncOperationMixin on ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  /// True while a [runLoad] task is in flight.
  bool get isLoading => _isLoading;

  /// Last error message produced by [runLoad] or [runMutate], or null.
  String? get error => _error;

  /// Reset [error] to null and notify listeners.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Run a load/refresh operation: flips [isLoading], catches errors into
  /// [error], and notifies listeners around both transitions. Does not rethrow.
  Future<void> runLoad(Future<void> Function() task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await task();
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Run a mutation operation: clears [error], invokes [task], notifies
  /// listeners on success, and (on failure) records [error], notifies, and
  /// rethrows so the caller can react.
  Future<T> runMutate<T>(Future<T> Function() task) async {
    _error = null;
    try {
      final result = await task();
      notifyListeners();
      return result;
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }
}
