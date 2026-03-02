import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/models.dart';

/// Provider for managing transaction list state throughout the app.
/// 
/// Extends [ChangeNotifier] to notify listeners when transactions are added,
/// removed, or modified. Provides CRUD operations for transactions.
class TransactionProvider extends ChangeNotifier {
  /// Internal list of transactions.
  List<Transaction> _transactions = [];
  
  /// Indicates whether a transaction operation is in progress.
  bool _isLoading = false;
  
  /// Stores the most recent error message, if any.
  String? _error;

  /// Returns an unmodifiable view of the transaction list.
  /// 
  /// Prevents external modification of the internal state.
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  
  /// Returns true if a transaction operation is in progress.
  bool get isLoading => _isLoading;
  
  /// Returns the most recent error message, or null if no error occurred.
  String? get error => _error;

  /// Fetches all transactions for the current user.
  /// 
  /// Optionally filters by [category] if provided.
  /// Sets [isLoading] to true during the fetch and updates [transactions] on success.
  /// Sets [error] if the fetch fails.
  /// Notifies listeners when state changes.
  // TODO: Future<void> fetchTransactions({String? category})
  
  /// Adds a new transaction.
  /// 
  /// Sends the [transaction] to the backend and adds it to the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> addTransaction(Transaction transaction)
  
  /// Deletes a transaction by its [id].
  /// 
  /// Removes the transaction from the backend and the local list on success.
  /// Sets [isLoading] to true during the operation and [error] on failure.
  /// Notifies listeners when state changes.
  // TODO: Future<void> deleteTransaction(String id)
}
