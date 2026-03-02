import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages savings-goal list state and CRUD operations.
class GoalProvider extends ChangeNotifier {
  late final GoalService _service;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalProvider({required ApiClient apiClient}) {
    _service = GoalService(apiClient);
  }

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Clears any previous error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _service.fetchGoals();
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    _error = null;
    try {
      final created = await _service.createGoal(goal);
      _goals.add(created);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateGoal(Goal goal) async {
    _error = null;
    try {
      final updated = await _service.updateGoal(goal);
      final idx = _goals.indexWhere((g) => g.id == goal.id);
      if (idx != -1) _goals[idx] = updated;
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteGoal(String id) async {
    _error = null;
    try {
      await _service.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }
}
