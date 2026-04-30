/// Goal repository - thin layer between [GoalProvider] and the HTTP service.
library;

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';

class GoalRepository {
  final GoalService _service;

  GoalRepository({required ApiClient apiClient, GoalService? service})
    : _service = service ?? GoalService(apiClient);

  Future<List<Goal>> fetch() => _service.fetchGoals();
  Future<Goal> create(Goal goal) => _service.createGoal(goal);
  Future<Goal> update(Goal goal) => _service.updateGoal(goal);
  Future<void> delete(String id) => _service.deleteGoal(id);
}
