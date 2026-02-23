import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/transaction_service.dart';

/// Manages the list of transactions and derived spending data.
class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;

  TransactionProvider(this._service);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Total spent across all transactions.
  double get totalSpent => _transactions.fold(0.0, (sum, t) => sum + t.amount);

  /// Spending grouped by category.
  Map<String, double> get spendingByCategory {
    final map = <String, double>{};
    for (final t in _transactions) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Fetch all transactions from the service.
  Future<void> loadTransactions() async {
    _setLoading(true);
    try {
      _transactions = await _service.getTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new transaction and prepend it to the list.
  Future<void> addTransaction({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    _setLoading(true);
    try {
      final t = await _service.addTransaction(
        amount: amount,
        category: category,
        description: description,
        date: date,
      );
      _transactions = [t, ..._transactions];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
