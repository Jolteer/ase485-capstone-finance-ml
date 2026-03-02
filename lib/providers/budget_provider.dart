import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/models.dart';

/// Provider for managing budget list state throughout the app.
/// 
/// Extends [ChangeNotifier] to notify listeners when budgets are added,
/// removed, or modified. Provides CRUD operations for budgets.
class BudgetProvider extends ChangeNotifier {
  /// Internal list of budgets.
  List<Budget> _budgets = [];
  
  /// Indicates whether a budget operation is in progress.
  bool _isLoading = false;
  
  /// Stores the most recent error message, if any.
  String? _error;

  /// Returns an unmodifiable view of the budget list.
  /// 
  /// Prevents external modification of the internal state.
  List<Budget> get budgets => List.unmodifiable(_budgets);
  
  /// Returns true if a budget operation is in progress.
  bool get isLoading => _isLoading;
  
  /// Returns the most recent error message, or null if no error occurred.
  String? get error => _error;

  /// Fetches all budgets for the current user.
  /// 
  /// Sets [isLoading] to true during the fetch and updates [budgets] on success.
  /// Sets [error] if the fetch fails.
  /// Notifies listeners when state changes.
  // TODO: Future<void> fetchBudgets()
  
  /// Adds a new budget.
  /// 
  /// Sends the [budget] to the backend and adds it to the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> addBudget(Budget budget)
  
  /// Updates an existing budget.
  /// 
  /// Sends the modified [budget] to the backend and updates the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> updateBudget(Budget budget)
  
  /// Deletes a budget by its [id].
  /// 
  /// Removes the budget from the backend and the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> deleteBudget(String id)
}
