import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles savings-goal CRUD operations via the API.
class GoalService {
  final ApiClient _api;

  GoalService(this._api);

  Future<List<Goal>> fetchGoals() async {
    final res = await _api.get('/goals');
    if (res.statusCode != 200) throw Exception('Failed to fetch goals');

    final list = jsonDecode(res.body) as List;
    return list.map((j) => Goal.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Goal> createGoal(Goal goal) async {
    final res = await _api.post(
      '/goals',
      body: {
        'target_amount': goal.targetAmount,
        'target_date': goal.targetDate.toIso8601String(),
        'description': goal.description,
        'progress': goal.progress,
      },
    );

    if (res.statusCode != 201) throw Exception('Failed to create goal');
    return Goal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Goal> updateGoal(Goal goal) async {
    final res = await _api.put(
      '/goals/${goal.id}',
      body: {
        'target_amount': goal.targetAmount,
        'target_date': goal.targetDate.toIso8601String(),
        'description': goal.description,
        'progress': goal.progress,
      },
    );

    if (res.statusCode != 200) throw Exception('Failed to update goal');
    return Goal.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteGoal(String id) async {
    final res = await _api.delete('/goals/$id');
    if (res.statusCode != 204) throw Exception('Failed to delete goal');
  }
}
