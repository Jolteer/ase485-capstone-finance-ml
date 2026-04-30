/// Transaction repository.
///
/// Sits between the [TransactionProvider] (UI state) and
/// [TransactionService] (HTTP). Today it's a thin pass-through, but having
/// the layer in place lets us add caching, optimistic updates, or local
/// persistence later without touching every provider.
library;

import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _service;

  TransactionRepository({
    required ApiClient apiClient,
    TransactionService? service,
  }) : _service = service ?? TransactionService(apiClient);

  Future<List<Transaction>> fetch({TransactionCategory? category}) =>
      _service.fetchTransactions(category: category);

  Future<Transaction> create(Transaction transaction) =>
      _service.createTransaction(transaction);

  Future<Transaction> update(Transaction transaction) =>
      _service.updateTransaction(transaction);

  Future<void> delete(String id) => _service.deleteTransaction(id);
}
