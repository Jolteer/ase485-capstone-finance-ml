/// Transaction list state and CRUD: fetch, add, update, delete.
///
/// Backed by [TransactionRepository]. The provider holds UI state
/// ([transactions], [isLoading], [error]); it never knows about HTTP.
library;

import 'package:flutter/foundation.dart';

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/repositories/transaction_repository.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/utils/async_operation_mixin.dart';

class TransactionProvider extends ChangeNotifier with AsyncOperationMixin {
  final TransactionRepository _repository;

  List<Transaction> _transactions = [];

  /// Pass [repository] in tests to inject a mock; production code provides
  /// [apiClient] and we build the default repository.
  TransactionProvider({
    required ApiClient apiClient,
    TransactionRepository? repository,
  }) : _repository = repository ?? TransactionRepository(apiClient: apiClient);

  /// Unmodifiable view of the loaded transactions.
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Fetches transactions; optional [category] filter. Updates [transactions].
  Future<void> fetchTransactions({TransactionCategory? category}) =>
      runLoad(() async {
        _transactions = await _repository.fetch(category: category);
      });

  /// Creates a transaction and inserts it at the top of the list.
  Future<void> addTransaction(Transaction transaction) => runMutate(() async {
    final created = await _repository.create(transaction);
    _transactions.insert(0, created);
  });

  /// Updates a transaction in place (matched by id).
  Future<void> updateTransaction(Transaction transaction) =>
      runMutate(() async {
        final updated = await _repository.update(transaction);
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index != -1) _transactions[index] = updated;
      });

  /// Deletes a transaction by id.
  Future<void> deleteTransaction(String id) => runMutate(() async {
    await _repository.delete(id);
    _transactions.removeWhere((t) => t.id == id);
  });
}
