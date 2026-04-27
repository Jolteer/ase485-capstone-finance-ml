/// Budget list state and CRUD: fetch, add, update, delete.
///
/// Use with [ChangeNotifierProvider]; requires [ApiClient]. Call [fetchBudgets]
/// to load; [budgets], [isLoading], and [error] notify listeners.
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

/// Manages the list of [Budget]s and delegates to [BudgetService] for API calls.
class BudgetProvider extends ChangeNotifier with AsyncOperationMixin {
  final BudgetService _service;

  List<Budget> _budgets = [];

  /// Pass [service] in tests to inject a mock; production code omits it and
  /// requires [apiClient] to construct the default [BudgetService].
  BudgetProvider({required ApiClient apiClient, BudgetService? service})
    : _service = service ?? BudgetService(apiClient);

  /// Unmodifiable list of budgets; load with [fetchBudgets].
  List<Budget> get budgets => List.unmodifiable(_budgets);

  /// Fetches budgets from the API and updates [budgets].
  Future<void> fetchBudgets() => runLoad(() async {
    _budgets = await _service.fetchBudgets();
  });

  /// Creates a budget via API and inserts it at the start of [budgets].
  Future<void> addBudget(Budget budget) => runMutate(() async {
    final created = await _service.createBudget(budget);
    _budgets.insert(0, created);
  });

  /// Updates a budget via API and replaces it in [budgets].
  Future<void> updateBudget(Budget budget) => runMutate(() async {
    final updated = await _service.updateBudget(budget);
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) _budgets[idx] = updated;
  });

  /// Deletes the budget with [id] via API and removes it from [budgets].
  Future<void> deleteBudget(String id) => runMutate(() async {
    await _service.deleteBudget(id);
    _budgets.removeWhere((b) => b.id == id);
  });

  /// Replaces all budgets with ML-generated suggestions based on transaction history.
  Future<void> generateBudgets() => runLoad(() async {
    _budgets = await _service.generateBudgets();
  });
}
