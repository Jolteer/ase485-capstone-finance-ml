/// Savings goal list state and CRUD: fetch, add, update, delete.
///
/// Backed by [GoalRepository].
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/repositories/goal_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

class GoalProvider extends ChangeNotifier with AsyncOperationMixin {
  final GoalRepository _repository;

  List<Goal> _goals = [];

  GoalProvider({required ApiClient apiClient, GoalRepository? repository})
    : _repository = repository ?? GoalRepository(apiClient: apiClient);

  /// Unmodifiable view of the loaded goals.
  List<Goal> get goals => List.unmodifiable(_goals);

  Future<void> fetchGoals() => runLoad(() async {
    _goals = await _repository.fetch();
  });

  Future<void> addGoal(Goal goal) => runMutate(() async {
    final created = await _repository.create(goal);
    _goals.add(created);
  });

  Future<void> updateGoal(Goal goal) => runMutate(() async {
    final updated = await _repository.update(goal);
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx != -1) _goals[idx] = updated;
  });

  Future<void> deleteGoal(String id) => runMutate(() async {
    await _repository.delete(id);
    _goals.removeWhere((g) => g.id == id);
  });
}
