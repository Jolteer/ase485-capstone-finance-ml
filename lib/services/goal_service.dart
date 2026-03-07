/// Savings-goal CRUD via API: fetch all, create, update, delete. Used by [GoalProvider].
///
/// All methods throw on non-success; paths use `/goals` and `/goals/:id`.
library;

import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles savings-goal CRUD operations via the API.
class GoalService {
  final ApiClient _api;

  GoalService(this._api);

  /// GET /goals; returns list of [Goal].
  Future<List<Goal>> fetchGoals() async {
    final res = await _api.get('/goals');
    if (res.statusCode != 200) throw Exception(ApiClient.extractError(res));

    final list = jsonDecode(res.body) as List;
    return list.map((j) => Goal.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// POST /goals; returns created [Goal] with id.
  ///
  /// Delegates serialization to [Goal.toJson] and strips server-managed
  /// fields ([id], [userId]) that the API generates on creation.
  Future<Goal> createGoal(Goal goal) async {
    final body = goal.toJson()
      ..remove('id')
      ..remove('user_id');

    final res = await _api.post('/goals', body: body);
    if (res.statusCode != 201) throw Exception(ApiClient.extractError(res));
    return Goal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// PUT /goals/:id; returns updated [Goal].
  ///
  /// Delegates serialization to [Goal.toJson] and strips server-managed
  /// fields ([id], [userId]).
  Future<Goal> updateGoal(Goal goal) async {
    final body = goal.toJson()
      ..remove('id')
      ..remove('user_id');

    final res = await _api.put('/goals/${goal.id}', body: body);
    if (res.statusCode != 200) throw Exception(ApiClient.extractError(res));
    return Goal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// DELETE /goals/:id.
  Future<void> deleteGoal(String id) async {
    final res = await _api.delete('/goals/$id');
    if (res.statusCode != 204) throw Exception(ApiClient.extractError(res));
  }
}
