import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

/// Manages transaction state and data loading.
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // TODO: Load transactions
  // TODO: Add transaction
  // TODO: Filter by category/date
}
