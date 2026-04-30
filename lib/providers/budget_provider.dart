/// Budget list state and CRUD: fetch, add, update, delete, regenerate.
///
/// Backed by [BudgetRepository].
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/repositories/budget_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

class BudgetProvider extends ChangeNotifier with AsyncOperationMixin {
  final BudgetRepository _repository;

  List<Budget> _budgets = [];

  BudgetProvider({required ApiClient apiClient, BudgetRepository? repository})
    : _repository = repository ?? BudgetRepository(apiClient: apiClient);

  /// Unmodifiable view of the loaded budgets.
  List<Budget> get budgets => List.unmodifiable(_budgets);

  Future<void> fetchBudgets() => runLoad(() async {
    _budgets = await _repository.fetch();
  });

  Future<void> addBudget(Budget budget) => runMutate(() async {
    final created = await _repository.create(budget);
    _budgets.insert(0, created);
  });

  Future<void> updateBudget(Budget budget) => runMutate(() async {
    final updated = await _repository.update(budget);
    final idx = _budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) _budgets[idx] = updated;
  });

  Future<void> deleteBudget(String id) => runMutate(() async {
    await _repository.delete(id);
    _budgets.removeWhere((b) => b.id == id);
  });

  /// Replaces every budget with ML-derived suggestions from history.
  Future<void> generateBudgets() => runLoad(() async {
    _budgets = await _repository.regenerateFromHistory();
  });
}
