import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';

/// State-management class for financial (savings) goals.
///
/// Keeps a reactive list of [Goal] objects and provides actions to
/// load, add, and remove goals while exposing loading/error state.
class GoalProvider extends ChangeNotifier {
  /// Service used to perform goal-related API calls.
  final GoalService _service;

  /// In-memory cache of the user’s financial goals.
  List<Goal> _goals = [];

  /// True while a network request is in progress.
  bool _isLoading = false;

  /// Human-readable error from the most recent failed call.
  String? _error;

  GoalProvider(this._service);

  // --------------- public getters ---------------

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --------------- actions ---------------

  /// Fetch all goals from the API and replace the local list.
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _service.getGoals();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new goal via the API and append the server-returned copy
  /// to the local list for instant UI feedback.
  Future<void> addGoal(Goal goal) async {
    try {
      final created = await _service.createGoal(goal);
      _goals.add(created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete a goal from the backend and remove it from the local list.
  Future<void> removeGoal(String id) async {
    await _service.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
