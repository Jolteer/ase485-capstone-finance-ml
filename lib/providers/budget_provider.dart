import 'package:flutter/foundation.dart';
import 'package:ase485_capstone_finance_ml/models/budget.dart';

/// Manages budget list state and exposes helpers for CRUD operations.
class BudgetProvider extends ChangeNotifier {
  // ignore: prefer_final_fields
  List<Budget> _budgets = [];
  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Future<void> fetchBudgets()
  // TODO: Future<void> addBudget(Budget budget)
  // TODO: Future<void> updateBudget(Budget budget)
  // TODO: Future<void> deleteBudget(String id)
}
