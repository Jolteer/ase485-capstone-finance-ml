/// Savings goal list state and CRUD: fetch, add, update, delete.
///
/// Use with [ChangeNotifierProvider]; requires [ApiClient]. Call [fetchGoals]
/// to load; [goals], [isLoading], and [error] notify listeners.
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

/// Manages the list of [Goal]s and delegates to [GoalService] for API calls.
class GoalProvider extends ChangeNotifier with AsyncOperationMixin {
  final GoalService _service;

  List<Goal> _goals = [];

  /// Pass [service] in tests to inject a mock; production code omits it and
  /// requires [apiClient] to construct the default [GoalService].
  GoalProvider({required ApiClient apiClient, GoalService? service})
    : _service = service ?? GoalService(apiClient);

  /// Unmodifiable list of goals; load with [fetchGoals].
  List<Goal> get goals => List.unmodifiable(_goals);

  /// Fetches goals from the API and updates [goals].
  Future<void> fetchGoals() => runLoad(() async {
    _goals = await _service.fetchGoals();
  });

  /// Creates a goal via API and appends it to [goals].
  Future<void> addGoal(Goal goal) => runMutate(() async {
    final created = await _service.createGoal(goal);
    _goals.add(created);
  });

  /// Updates a goal via API and replaces it in [goals].
  Future<void> updateGoal(Goal goal) => runMutate(() async {
    final updated = await _service.updateGoal(goal);
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _goals[idx] = updated;
  });

  /// Deletes the goal with [id] via API and removes it from [goals].
  Future<void> deleteGoal(String id) => runMutate(() async {
    await _service.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
  });
}
