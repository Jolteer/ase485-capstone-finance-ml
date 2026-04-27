/// Transaction CRUD via API: fetch (optional category filter), create, delete. Used by [TransactionProvider].
///
/// All methods throw on non-success; paths use `/transactions` and `/transactions/:id`.
library;

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
    return ApiClient.decodeJsonList(res, Transaction.fromJson);
  }

  /// POST /transactions; returns created [Transaction] with id.
  ///
  /// Strips server-managed fields ([id], [userId]) since the API generates
  /// them on creation.
  Future<Transaction> createTransaction(Transaction transaction) async {
    final res = await _api.post(
      '/transactions',
      body: _stripServerFields(transaction),
    );
    return ApiClient.decodeJsonObject(res, Transaction.fromJson, expected: 201);
  }

  /// PUT /transactions/:id; returns the updated [Transaction].
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final res = await _api.put(
      '/transactions/${transaction.id}',
      body: _stripServerFields(transaction),
    );
    return ApiClient.decodeJsonObject(res, Transaction.fromJson);
  }

  /// DELETE /transactions/:id.
  Future<void> deleteTransaction(String id) async {
    final res = await _api.delete('/transactions/$id');
    ApiClient.expectStatus(res, 204);
  }

  Map<String, dynamic> _stripServerFields(Transaction transaction) =>
      transaction.toJson()
        ..remove('id')
        ..remove('user_id');
}
