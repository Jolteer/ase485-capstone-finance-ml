/// Savings-goal CRUD via API: fetch all, create, update, delete. Used by [GoalProvider].
///
/// All methods throw on non-success; paths use `/goals` and `/goals/:id`.
library;

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles savings-goal CRUD operations via the API.
class GoalService {
  final ApiClient _api;

  GoalService(this._api);

  /// GET /goals; returns list of [Goal].
  Future<List<Goal>> fetchGoals() async {
    final res = await _api.get('/goals');
    return ApiClient.decodeJsonList(res, Goal.fromJson);
  }

  /// POST /goals; returns created [Goal] with id.
  ///
  /// Strips server-managed fields ([id], [userId]) since the API generates
  /// them on creation.
  Future<Goal> createGoal(Goal goal) async {
    final res = await _api.post('/goals', body: _stripServerFields(goal));
    return ApiClient.decodeJsonObject(res, Goal.fromJson, expected: 201);
  }

  /// PUT /goals/:id; returns updated [Goal].
  Future<Goal> updateGoal(Goal goal) async {
    final res = await _api.put(
      '/goals/${goal.id}',
      body: _stripServerFields(goal),
    );
    return ApiClient.decodeJsonObject(res, Goal.fromJson);
  }

  /// DELETE /goals/:id.
  Future<void> deleteGoal(String id) async {
    final res = await _api.delete('/goals/$id');
    ApiClient.expectStatus(res, 204);
  }

  Map<String, dynamic> _stripServerFields(Goal goal) => goal.toJson()
    ..remove('id')
    ..remove('user_id');
}
