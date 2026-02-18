import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service for CRUD operations on financial goals.
///
/// Goals let users set a savings target (e.g. “$2 000 for vacation by Dec”)
/// and track progress over time.
class GoalService {
  final ApiClient _api;

  GoalService(this._api);

  /// Fetch all goals belonging to the authenticated user.
  Future<List<Goal>> getGoals() async {
    final data = await _api.get('/goals');
    final items = data['items'] as List;
    return items
        .map((json) => Goal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new goal on the backend and return the saved copy.
  Future<Goal> createGoal(Goal goal) async {
    final data = await _api.post('/goals', goal.toJson());
    return Goal.fromJson(data);
  }

  /// Update an existing goal (e.g. adjust target or log progress).
  Future<Goal> updateGoal(Goal goal) async {
    final data = await _api.put('/goals/${goal.id}', goal.toJson());
    return Goal.fromJson(data);
  }

  /// Delete a goal by its [id].
  Future<void> deleteGoal(String id) async {
    await _api.delete('/goals/$id');
  }
}
