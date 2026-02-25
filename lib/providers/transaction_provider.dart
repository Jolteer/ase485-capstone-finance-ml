import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

/// Manages transaction list state and CRUD operations.
class TransactionProvider extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<Transaction> _transactions = [];
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Future<void> fetchTransactions({String? category})
  // TODO: Future<void> addTransaction(Transaction transaction)
  // TODO: Future<void> deleteTransaction(String id)
}
