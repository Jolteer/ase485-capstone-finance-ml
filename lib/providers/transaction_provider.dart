/// Transaction list state and CRUD: fetch (optional category filter), add, delete.
///
/// Use with [ChangeNotifierProvider]; requires [ApiClient] for API calls. Call
/// [fetchTransactions] to load; [transactions], [isLoading], and [error] notify listeners.
import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages the list of [Transaction]s and delegates to [TransactionService] for API calls.
class TransactionProvider extends ChangeNotifier {
  late final TransactionService _service;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider({required ApiClient apiClient}) {
    _service = TransactionService(apiClient);
  }

  /// Unmodifiable list of transactions; load with [fetchTransactions].
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// True while [fetchTransactions] or another async operation is running.
  bool get isLoading => _isLoading;

  /// Last error from a transaction operation, or null. Clear with [clearError].
  String? get error => _error;

  /// Clears [error] and notifies listeners.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetches transactions from the API; optional [category] filter. Updates [transactions].
  Future<void> fetchTransactions({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _service.fetchTransactions(category: category);
    } catch (e) {
      _error = formatError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a transaction via API and inserts it at the start of [transactions].
  Future<void> addTransaction(Transaction transaction) async {
    _error = null;
    try {
      final created = await _service.createTransaction(transaction);
      _transactions.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes the transaction with [id] via API and removes it from [transactions].
  Future<void> deleteTransaction(String id) async {
    _error = null;
    try {
      await _service.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = formatError(e);
      notifyListeners();
      rethrow;
    }
  }
}
