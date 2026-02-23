import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/mock_api_client.dart';

/// Fetches and creates transactions via the API or mock data.
class TransactionService {
  final ApiClient _api;

  TransactionService(this._api);

  /// Get all transactions for the current user.
  Future<List<Transaction>> getTransactions() async {
    if (useMockApi) return MockApiClient.getTransactions();
    final json = await _api.get('/transactions');
    final list = json['data'] as List;
    return list
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new transaction and return the saved object.
  Future<Transaction> addTransaction({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    if (useMockApi) {
      return MockApiClient.addTransaction(
        amount: amount,
        category: category,
        description: description,
        date: date,
      );
    }
    final json = await _api.post(
      '/transactions',
      body: {
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
      },
    );
    return Transaction.fromJson(json);
  }
}
