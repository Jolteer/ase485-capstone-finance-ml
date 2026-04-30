/// Budget repository - thin layer between [BudgetProvider] and the HTTP service.
library;

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/budget_service.dart';

class BudgetRepository {
  final BudgetService _service;

  BudgetRepository({required ApiClient apiClient, BudgetService? service})
    : _service = service ?? BudgetService(apiClient);

  Future<List<Budget>> fetch() => _service.fetchBudgets();
  Future<Budget> create(Budget budget) => _service.createBudget(budget);
  Future<Budget> update(Budget budget) => _service.updateBudget(budget);
  Future<void> delete(String id) => _service.deleteBudget(id);

  /// Replaces every budget for the current user with ML-generated suggestions.
  Future<List<Budget>> regenerateFromHistory() => _service.generateBudgets();
}
