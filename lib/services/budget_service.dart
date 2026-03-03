/// Budget CRUD via API: fetch all, create, update, delete. Used by [BudgetProvider].
///
/// All methods throw on non-success; paths use `/budgets` and `/budgets/:id`.
import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles budget CRUD operations via the API.
class BudgetService {
  final ApiClient _api;

  BudgetService(this._api);

  /// GET /budgets; returns list of [Budget].
  Future<List<Budget>> fetchBudgets() async {
    final res = await _api.get('/budgets');
    if (res.statusCode != 200) throw Exception('Failed to fetch budgets');

    final list = jsonDecode(res.body) as List;
    return list.map((j) => Budget.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// POST /budgets; returns created [Budget] with id.
  Future<Budget> createBudget(Budget budget) async {
    final res = await _api.post(
      '/budgets',
      body: {
        'category': budget.category,
        'limit_amount': budget.limitAmount,
        'period': budget.period,
      },
    );

    if (res.statusCode != 201) throw Exception('Failed to create budget');
    return Budget.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// PUT /budgets/:id; returns updated [Budget].
  Future<Budget> updateBudget(Budget budget) async {
    final res = await _api.put(
      '/budgets/${budget.id}',
      body: {
        'category': budget.category,
        'limit_amount': budget.limitAmount,
        'period': budget.period,
      },
    );

    if (res.statusCode != 200) throw Exception('Failed to update budget');
    return Budget.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// DELETE /budgets/:id.
  Future<void> deleteBudget(String id) async {
    final res = await _api.delete('/budgets/$id');
    if (res.statusCode != 204) throw Exception('Failed to delete budget');
  }
}
