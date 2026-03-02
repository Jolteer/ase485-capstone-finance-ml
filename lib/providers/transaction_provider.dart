import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';
import 'package:ase485_capstone_finance_ml/utils/error_helpers.dart';

/// Manages transaction list state and CRUD operations.
class TransactionProvider extends ChangeNotifier {
  late final TransactionService _service;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider({required ApiClient apiClient}) {
    _service = TransactionService(apiClient);
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Clears any previous error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

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
