/// Transaction list state and CRUD: fetch (optional category filter), add, delete.
///
/// Use with [ChangeNotifierProvider]; requires [ApiClient] for API calls. Call
/// [fetchTransactions] to load; [transactions], [isLoading], and [error] notify listeners.
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

/// Manages the list of [Transaction]s and delegates to [TransactionService] for API calls.
class TransactionProvider extends ChangeNotifier with AsyncOperationMixin {
  final TransactionService _service;

  List<Transaction> _transactions = [];

  /// Pass [service] in tests to inject a mock; production code omits it and
  /// requires [apiClient] to construct the default [TransactionService].
  TransactionProvider({
    required ApiClient apiClient,
    TransactionService? service,
  }) : _service = service ?? TransactionService(apiClient);

  /// Unmodifiable list of transactions; load with [fetchTransactions].
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Fetches transactions from the API; optional [category] filter. Updates [transactions].
  Future<void> fetchTransactions({TransactionCategory? category}) =>
      runLoad(() async {
        _transactions = await _service.fetchTransactions(category: category);
      });

  /// Creates a transaction via API and inserts it at the start of [transactions].
  Future<void> addTransaction(Transaction transaction) => runMutate(() async {
    final created = await _service.createTransaction(transaction);
    _transactions.insert(0, created);
  });

  /// Updates [transaction] via API and replaces the matching entry in [transactions].
  Future<void> updateTransaction(Transaction transaction) =>
      runMutate(() async {
        final updated = await _service.updateTransaction(transaction);
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) _transactions[index] = updated;
      });

  /// Deletes the transaction with [id] via API and removes it from [transactions].
  Future<void> deleteTransaction(String id) => runMutate(() async {
    await _service.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
  });
}
