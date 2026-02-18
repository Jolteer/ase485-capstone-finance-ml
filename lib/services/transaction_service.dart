import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/services/api_client.dart';

/// Service responsible for all transaction-related API calls.
///
/// Supports:
/// • Paginated listing with optional filters (category, date range).
/// • Creating, updating, and deleting individual transactions.
/// • Bulk-importing transactions from CSV data.
class TransactionService {
  final ApiClient _api;

  TransactionService(this._api);

  /// Fetch a paginated list of transactions from the API.
  ///
  /// Optional filters:
  /// - [category]  – only return transactions in this category.
  /// - [startDate] – exclude transactions before this date.
  /// - [endDate]   – exclude transactions after this date.
  ///
  /// Query parameters are built dynamically and appended to the URL.
  /// The API returns `{ "items": [ ... ] }` which is mapped to a
  /// `List<Transaction>`.
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Start with mandatory pagination params.
    final queryParams = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
    };
    // Conditionally add optional filter params.
    if (category != null) queryParams['category'] = category;
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }
    // Encode query params into a URL query string.
    final query = Uri(queryParameters: queryParams).query;
    final data = await _api.get('/transactions?$query');
    // Parse each JSON object in the "items" list into a Transaction.
    final items = data['items'] as List;
    return items
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new transaction on the backend and return the saved copy
  /// (which now includes the server-generated [id]).
  Future<Transaction> createTransaction(Transaction transaction) async {
    final data = await _api.post('/transactions', transaction.toJson());
    return Transaction.fromJson(data);
  }

  /// Update an existing transaction by its [id] and return the updated copy.
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final data = await _api.put(
      '/transactions/${transaction.id}',
      transaction.toJson(),
    );
    return Transaction.fromJson(data);
  }

  /// Permanently delete a transaction by its [id].
  Future<void> deleteTransaction(String id) async {
    await _api.delete('/transactions/$id');
  }

  /// Bulk-import transactions from raw CSV text.
  ///
  /// The backend parses the CSV, auto-categorises each row using the ML
  /// model, and returns the created transactions.
  Future<List<Transaction>> importTransactions(String csvData) async {
    final data = await _api.post('/transactions/import', {'csv': csvData});
    final items = data['items'] as List;
    return items
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
