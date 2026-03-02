import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/models.dart';

/// Provider for managing savings goal list state throughout the app.
/// 
/// Extends [ChangeNotifier] to notify listeners when goals are added,
/// removed, or modified. Provides CRUD operations for savings goals.
class GoalProvider extends ChangeNotifier {
  /// Internal list of savings goals.
  List<Goal> _goals = [];
  
  /// Indicates whether a goal operation is in progress.
  bool _isLoading = false;
  
  /// Stores the most recent error message, if any.
  String? _error;

  /// Returns an unmodifiable view of the goals list.
  /// 
  /// Prevents external modification of the internal state.
  List<Goal> get goals => List.unmodifiable(_goals);
  
  /// Returns true if a goal operation is in progress.
  bool get isLoading => _isLoading;
  
  /// Returns the most recent error message, or null if no error occurred.
  String? get error => _error;

  /// Fetches all savings goals for the current user.
  /// 
  /// Sets [isLoading] to true during the fetch and updates [goals] on success.
  /// Sets [error] if the fetch fails.
  /// Notifies listeners when state changes.
  // TODO: Future<void> fetchGoals()
  
  /// Adds a new savings goal.
  /// 
  /// Sends the [goal] to the backend and adds it to the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> addGoal(Goal goal)
  
  /// Updates an existing savings goal.
  /// 
  /// Sends the modified [goal] to the backend and updates the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> updateGoal(Goal goal)
  
  /// Deletes a savings goal by its [id].
  /// 
  /// Removes the goal from the backend and the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> deleteGoal(String id)
}
