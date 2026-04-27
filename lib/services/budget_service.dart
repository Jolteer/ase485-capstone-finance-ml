/// Budget CRUD via API: fetch all, create, update, delete. Used by [BudgetProvider].
///
/// All methods throw on non-success; paths use `/budgets` and `/budgets/:id`.
library;

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles budget CRUD operations via the API.
class BudgetService {
  final ApiClient _api;

  BudgetService(this._api);

  /// GET /budgets; returns list of [Budget].
  Future<List<Budget>> fetchBudgets() async {
    final res = await _api.get('/budgets');
    return ApiClient.decodeJsonList(res, Budget.fromJson);
  }

  /// POST /budgets; returns created [Budget] with id.
  ///
  /// Strips server-managed fields ([id], [userId], [createdAt]) since the API
  /// generates them on creation.
  Future<Budget> createBudget(Budget budget) async {
    final res = await _api.post('/budgets', body: _stripServerFields(budget));
    return ApiClient.decodeJsonObject(res, Budget.fromJson, expected: 201);
  }

  /// PUT /budgets/:id; returns updated [Budget].
  Future<Budget> updateBudget(Budget budget) async {
    final res = await _api.put(
      '/budgets/${budget.id}',
      body: _stripServerFields(budget),
    );
    return ApiClient.decodeJsonObject(res, Budget.fromJson);
  }

  /// DELETE /budgets/:id.
  Future<void> deleteBudget(String id) async {
    final res = await _api.delete('/budgets/$id');
    ApiClient.expectStatus(res, 204);
  }

  /// POST /ml/budgets/generate; replaces current budgets with ML-generated ones.
  Future<List<Budget>> generateBudgets() async {
    final res = await _api.post('/ml/budgets/generate');
    return ApiClient.decodeJsonList(res, Budget.fromJson);
  }

  Map<String, dynamic> _stripServerFields(Budget budget) => budget.toJson()
    ..remove('id')
    ..remove('user_id')
    ..remove('created_at');
}
