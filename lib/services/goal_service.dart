import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service layer for savings goal data management.
/// 
/// Provides CRUD (Create, Read, Update, Delete) operations for savings
/// goals by communicating with the backend API through [ApiClient].
class GoalService {
  /// The API client used for making HTTP requests.
  final ApiClient _api;

  /// Creates a [GoalService] instance with the given [ApiClient].
  GoalService(this._api);

  /// Fetches all savings goals for the current user.
  /// 
  /// Returns a list of [Goal] objects.
  /// Throws an exception if the fetch fails.
  // TODO: Future<List<Goal>> fetchGoals()
  
  /// Creates a new savings goal.
  /// 
  /// Sends the [goal] data to the backend and returns the created
  /// [Goal] with server-assigned ID and timestamp.
  /// Throws an exception if creation fails.
  // TODO: Future<Goal> createGoal(Goal goal)
  
  /// Updates an existing savings goal.
  /// 
  /// Sends the modified [goal] data to the backend and returns
  /// the updated [Goal].
  /// Throws an exception if update fails (e.g., goal not found).
  // TODO: Future<Goal> updateGoal(Goal goal)
  
  /// Deletes a savings goal by its [id].
  /// 
  /// Removes the goal from the backend.
  /// Throws an exception if deletion fails (e.g., goal not found).
  // TODO: Future<void> deleteGoal(String id)
}
