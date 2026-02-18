import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';

/// State-management class for the user’s transaction list.
///
/// Holds a reactive `List<Transaction>` and exposes loading/error state
/// so the UI can show spinners and error banners.
class TransactionProvider extends ChangeNotifier {
  /// Service used to perform API calls for transactions.
  final TransactionService _service;

  /// In-memory cache of the user’s transactions.
  List<Transaction> _transactions = [];

  /// True while a network request is in progress.
  bool _isLoading = false;

  /// Last error message, or null if the previous operation succeeded.
  String? _error;

  TransactionProvider(this._service);

  // --------------- public getters ---------------

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --------------- actions ---------------

  /// Fetch transactions from the API, optionally filtering by [category]
  /// and/or a date range. Replaces the current in-memory list.
  Future<void> loadTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _service.getTransactions(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new transaction via the API and insert the server-returned
  /// copy at the top of the local list for instant UI feedback.
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final created = await _service.createTransaction(transaction);
      _transactions.insert(0, created);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete a transaction from the backend and remove it from the local
  /// list so the UI updates immediately.
  Future<void> removeTransaction(String id) async {
    await _service.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
