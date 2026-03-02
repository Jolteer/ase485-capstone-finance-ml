import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service layer for transaction data management.
/// 
/// Provides CRUD (Create, Read, Update, Delete) operations for financial
/// transactions by communicating with the backend API through [ApiClient].
class TransactionService {
  /// The API client used for making HTTP requests.
  final ApiClient _api;

  /// Creates a [TransactionService] instance with the given [ApiClient].
  TransactionService(this._api);

  /// Fetches all transactions for the current user.
  /// 
  /// Optionally filters by [category] if provided.
  /// Returns a list of [Transaction] objects.
  /// Throws an exception if the fetch fails.
  // TODO: Future<List<Transaction>> fetchTransactions({String? category})
  
  /// Creates a new transaction.
  /// 
  /// Sends the [transaction] data to the backend and returns the created
  /// [Transaction] with server-assigned ID and timestamp.
  /// Throws an exception if creation fails.
  // TODO: Future<Transaction> createTransaction(Transaction transaction)
  
  /// Deletes a transaction by its [id].
  /// 
  /// Removes the transaction from the backend.
  /// Throws an exception if deletion fails (e.g., transaction not found).
  // TODO: Future<void> deleteTransaction(String id)
}
