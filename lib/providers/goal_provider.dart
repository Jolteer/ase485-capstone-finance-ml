import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/goal_service.dart';

/// Manages the list of savings goals and completion tracking.
class GoalProvider extends ChangeNotifier {
  final GoalService _service;

  GoalProvider(this._service);

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Number of goals that have been completed.
  int get completedCount => _goals.where((g) => g.isCompleted).length;

  /// Fetch all goals from the service.
  Future<void> loadGoals() async {
    _setLoading(true);
    try {
      _goals = await _service.getGoals();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new goal and append it to the list.
  Future<void> addGoal({
    required double targetAmount,
    required DateTime targetDate,
    required String description,
  }) async {
    _setLoading(true);
    try {
      final g = await _service.addGoal(
        targetAmount: targetAmount,
        targetDate: targetDate,
        description: description,
      );
      _goals = [..._goals, g];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
