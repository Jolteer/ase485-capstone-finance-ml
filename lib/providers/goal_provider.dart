import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';

/// Manages savings-goal list state and CRUD operations.
class GoalProvider extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<Goal> _goals = [];
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Future<void> fetchGoals()
  // TODO: Future<void> addGoal(Goal goal)
  // TODO: Future<void> updateGoal(Goal goal)
  // TODO: Future<void> deleteGoal(String id)
}
