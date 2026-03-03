/// Budget list state and CRUD: fetch, add, update, delete.
///
/// Use with [ChangeNotifierProvider]; requires [ApiClient]. Call [fetchBudgets]
/// to load; [budgets], [isLoading], and [error] notify listeners.
import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages the list of [Budget]s and delegates to [BudgetService] for API calls.
class BudgetProvider extends ChangeNotifier {
  late final BudgetService _service;

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  BudgetProvider({required ApiClient apiClient}) {
    _service = BudgetService(apiClient);
  }

  /// Unmodifiable list of budgets; load with [fetchBudgets].
  List<Budget> get budgets => List.unmodifiable(_budgets);

  /// True while [fetchBudgets] is running.
  bool get isLoading => _isLoading;

  /// Last error from a budget operation, or null. Clear with [clearError].
  String? get error => _error;

  /// Clears [error] and notifies listeners.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetches budgets from the API and updates [budgets].
  Future<void> fetchBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _service.fetchBudgets();
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a budget via API and inserts it at the start of [budgets].
  Future<void> addBudget(Budget budget) async {
    _error = null;
    try {
      final created = await _service.createBudget(budget);
      _budgets.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Updates a budget via API and replaces it in [budgets].
  Future<void> updateBudget(Budget budget) async {
    _error = null;
    try {
      final updated = await _service.updateBudget(budget);
      final idx = _budgets.indexWhere((b) => b.id == budget.id);
      if (idx != -1) _budgets[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes the budget with [id] via API and removes it from [budgets].
  Future<void> deleteBudget(String id) async {
    _error = null;
    try {
      await _service.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }
}
