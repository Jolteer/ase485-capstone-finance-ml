import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/mock_api_client.dart';

/// Fetches and creates budgets via the API or mock data.
class BudgetService {
  final ApiClient _api;

  BudgetService(this._api);

  /// Get all budgets for the current user.
  Future<List<Budget>> getBudgets() async {
    if (useMockApi) return MockApiClient.getBudgets();
    final json = await _api.get('/budgets');
    final list = json['data'] as List;
    return list.map((e) => Budget.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Create a new budget and return the saved object.
  Future<Budget> addBudget({
    required String category,
    required double limitAmount,
    required String period,
  }) async {
    if (useMockApi) {
      return MockApiClient.addBudget(
        category: category,
        limitAmount: limitAmount,
        period: period,
      );
    }
    final json = await _api.post(
      '/budgets',
      body: {
        'category': category,
        'limit_amount': limitAmount,
        'period': period,
      },
    );
    return Budget.fromJson(json);
  }
}
