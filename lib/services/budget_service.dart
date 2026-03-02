import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service layer for budget data management.
/// 
/// Provides CRUD (Create, Read, Update, Delete) operations for spending
/// budgets by communicating with the backend API through [ApiClient].
class BudgetService {
  /// The API client used for making HTTP requests.
  final ApiClient _api;

  /// Creates a [BudgetService] instance with the given [ApiClient].
  BudgetService(this._api);

  /// Fetches all budgets for the current user.
  /// 
  /// Returns a list of [Budget] objects.
  /// Throws an exception if the fetch fails.
  // TODO: Future<List<Budget>> fetchBudgets()
  
  /// Creates a new budget.
  /// 
  /// Sends the [budget] data to the backend and returns the created
  /// [Budget] with server-assigned ID and timestamp.
  /// Throws an exception if creation fails.
  // TODO: Future<Budget> createBudget(Budget budget)
  
  /// Updates an existing budget.
  /// 
  /// Sends the modified [budget] data to the backend and returns
  /// the updated [Budget].
  /// Throws an exception if update fails (e.g., budget not found).
  // TODO: Future<Budget> updateBudget(Budget budget)
  
  /// Deletes a budget by its [id].
  /// 
  /// Removes the budget from the backend.
  /// Throws an exception if deletion fails (e.g., budget not found).
  // TODO: Future<void> deleteBudget(String id)
}
