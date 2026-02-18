import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service for budget-related API operations.
///
/// • [getBudgets]      – retrieve all budgets for the authenticated user.
/// • [generateBudget]  – ask the ML pipeline to create a personalised budget.
/// • [updateBudget]    – modify a single budget (e.g. adjust the limit).
/// • [deleteBudget]    – remove a budget.
class BudgetService {
  final ApiClient _api;

  BudgetService(this._api);

  /// Fetch every budget belonging to the current user.
  Future<List<Budget>> getBudgets() async {
    final data = await _api.get('/budgets');
    final items = data['items'] as List;
    return items
        .map((json) => Budget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Tell the ML backend to analyse the user’s spending history and
  /// generate a set of personalised per-category budgets.
  /// Returns the newly created [Budget] list.
  Future<List<Budget>> generateBudget() async {
    final data = await _api.post('/budgets/generate', {});
    final items = data['items'] as List;
    return items
        .map((json) => Budget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Update a single [budget] (e.g. the user manually adjusts a limit).
  Future<Budget> updateBudget(Budget budget) async {
    final data = await _api.put('/budgets/${budget.id}', budget.toJson());
    return Budget.fromJson(data);
  }

  /// Delete a budget by its [id].
  Future<void> deleteBudget(String id) async {
    await _api.delete('/budgets/$id');
  }
}
