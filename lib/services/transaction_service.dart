import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles transaction CRUD operations via the API.
class TransactionService {
  final ApiClient _api;

  TransactionService(this._api);

  Future<List<Transaction>> fetchTransactions({String? category}) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category;

    final res = await _api.get(
      '/transactions',
      queryParams: params.isNotEmpty ? params : null,
    );
    if (res.statusCode != 200) throw Exception('Failed to fetch transactions');

    final list = jsonDecode(res.body) as List;
    return list
        .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    final res = await _api.post(
      '/transactions',
      body: {
        'amount': transaction.amount,
        'category': transaction.category,
        'description': transaction.description,
        'date': transaction.date.toIso8601String(),
      },
    );

    if (res.statusCode != 201) throw Exception('Failed to create transaction');
    return Transaction.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    final res = await _api.delete('/transactions/$id');
    if (res.statusCode != 204) throw Exception('Failed to delete transaction');
  }
}
