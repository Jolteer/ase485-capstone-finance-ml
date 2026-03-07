/// Transaction CRUD via API: fetch (optional category filter), create, delete. Used by [TransactionProvider].
///
/// All methods throw on non-success; paths use `/transactions` and `/transactions/:id`.
library;

import 'dart:convert';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Handles transaction CRUD operations via the API.
class TransactionService {
  final ApiClient _api;

  TransactionService(this._api);

  /// GET /transactions; optional [category] filter; returns list of [Transaction].
  Future<List<Transaction>> fetchTransactions({
    TransactionCategory? category,
  }) async {
    final params = category != null ? {'category': category.name} : null;

    final res = await _api.get('/transactions', queryParams: params);
    if (res.statusCode != 200) throw Exception(ApiClient.extractError(res));

    final list = jsonDecode(res.body) as List;
    return list
        .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// POST /transactions; returns created [Transaction] with id.
  ///
  /// Delegates serialization to [Transaction.toJson] and strips server-managed
  /// fields ([id], [userId]) that the API generates on creation.
  Future<Transaction> createTransaction(Transaction transaction) async {
    final body = transaction.toJson()
      ..remove('id')
      ..remove('user_id');

    final res = await _api.post('/transactions', body: body);
    if (res.statusCode != 201) throw Exception(ApiClient.extractError(res));
    return Transaction.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// PUT /transactions/:id; returns the updated [Transaction].
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final body = transaction.toJson()
      ..remove('id')
      ..remove('user_id');

    final res = await _api.put('/transactions/${transaction.id}', body: body);
    if (res.statusCode != 200) throw Exception(ApiClient.extractError(res));
    return Transaction.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// DELETE /transactions/:id.
  Future<void> deleteTransaction(String id) async {
    final res = await _api.delete('/transactions/$id');
    if (res.statusCode != 204) throw Exception(ApiClient.extractError(res));
  }
}
