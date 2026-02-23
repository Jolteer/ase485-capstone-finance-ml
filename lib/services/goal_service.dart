import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/mock_api_client.dart';

/// Fetches and creates savings goals via the API or mock data.
class GoalService {
  final ApiClient _api;

  GoalService(this._api);

  /// Get all goals for the current user.
  Future<List<Goal>> getGoals() async {
    if (useMockApi) return MockApiClient.getGoals();
    final json = await _api.get('/goals');
    final list = json['data'] as List;
    return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Create a new savings goal and return the saved object.
  Future<Goal> addGoal({
    required double targetAmount,
    required DateTime targetDate,
    required String description,
  }) async {
    if (useMockApi) {
      return MockApiClient.addGoal(
        targetAmount: targetAmount,
        targetDate: targetDate,
        description: description,
      );
    }
    final json = await _api.post(
      '/goals',
      body: {
        'target_amount': targetAmount,
        'target_date': targetDate.toIso8601String(),
        'description': description,
      },
    );
    return Goal.fromJson(json);
  }
}
