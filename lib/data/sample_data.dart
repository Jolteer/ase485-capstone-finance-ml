/// Sample/mock data for development and fallback UI.
///
/// Shared lists of [Transaction], [Goal], [BudgetItem], [CategoryBreakdown],
/// and [Recommendation] used when the backend is unavailable or for demos.
/// Replace with real provider/service data in production.
library;

import 'package:ase485_capstone_finance_ml/viewmodels/budget_item.dart';
import 'package:ase485_capstone_finance_ml/viewmodels/category_breakdown.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

export 'package:ase485_capstone_finance_ml/viewmodels/budget_item.dart';
export 'package:ase485_capstone_finance_ml/viewmodels/category_breakdown.dart';

// ---------------------------------------------------------------------------
// Transactions (sample list for demo/fallback when API is unavailable)
// ---------------------------------------------------------------------------

final sampleTransactions = [
  Transaction(
    id: '1',
    userId: 'demo',
    amount: -85.40,
    category: TransactionCategory.food,
    description: 'Grocery Store',
    date: DateTime(2026, 2, 22),
  ),
  Transaction(
    id: '2',
    userId: 'demo',
    amount: -120.00,
    category: TransactionCategory.bills,
    description: 'Electric Bill',
    date: DateTime(2026, 2, 20),
  ),
  Transaction(
    id: '3',
    userId: 'demo',
    amount: 3200.00,
    category: TransactionCategory.other,
    description: 'Salary Deposit',
    date: DateTime(2026, 2, 15),
  ),
  Transaction(
    id: '4',
    userId: 'demo',
    amount: -15.99,
    category: TransactionCategory.entertainment,
    description: 'Netflix',
    date: DateTime(2026, 2, 14),
  ),
  Transaction(
    id: '5',
    userId: 'demo',
    amount: -45.00,
    category: TransactionCategory.transportation,
    description: 'Gas Station',
    date: DateTime(2026, 2, 13),
  ),
  Transaction(
    id: '6',
    userId: 'demo',
    amount: -67.30,
    category: TransactionCategory.shopping,
    description: 'Amazon Order',
    date: DateTime(2026, 2, 12),
  ),
  Transaction(
    id: '7',
    userId: 'demo',
    amount: -24.50,
    category: TransactionCategory.healthcare,
    description: 'Pharmacy',
    date: DateTime(2026, 2, 10),
  ),
  Transaction(
    id: '8',
    userId: 'demo',
    amount: -49.99,
    category: TransactionCategory.education,
    description: 'Online Course',
    date: DateTime(2026, 2, 8),
  ),
];

/// First 5 transactions for the home dashboard "recent" view.
final recentTransactions = sampleTransactions.take(5).toList();

// ---------------------------------------------------------------------------
// Goals (sample savings goals for demo/fallback)
// ---------------------------------------------------------------------------

final sampleGoals = [
  Goal(
    id: '1',
    userId: 'demo',
    description: 'Vacation Fund',
    progress: 1800,
    targetAmount: 3000,
    targetDate: DateTime(2026, 6),
    category: GoalCategory.vacation,
  ),
  Goal(
    id: '2',
    userId: 'demo',
    description: 'Down Payment',
    progress: 12000,
    targetAmount: 50000,
    targetDate: DateTime(2027, 12),
    category: GoalCategory.home,
  ),
  Goal(
    id: '3',
    userId: 'demo',
    description: 'Emergency Fund',
    progress: 5000,
    targetAmount: 5000,
    targetDate: DateTime(2026, 1),
    category: GoalCategory.emergency,
  ),
  Goal(
    id: '4',
    userId: 'demo',
    description: 'New Car',
    progress: 3200,
    targetAmount: 15000,
    targetDate: DateTime(2027, 3),
    category: GoalCategory.car,
  ),
];

// ---------------------------------------------------------------------------
// Budget items (category spent/limit for budget screen)
// ---------------------------------------------------------------------------

const sampleBudgetItems = [
  BudgetItem(category: TransactionCategory.food, spent: 420, limit: 500),
  BudgetItem(
    category: TransactionCategory.entertainment,
    spent: 180,
    limit: 200,
  ),
  BudgetItem(category: TransactionCategory.bills, spent: 650, limit: 600),
  BudgetItem(category: TransactionCategory.shopping, spent: 210, limit: 300),
  BudgetItem(
    category: TransactionCategory.transportation,
    spent: 160,
    limit: 200,
  ),
  BudgetItem(category: TransactionCategory.healthcare, spent: 80, limit: 150),
  BudgetItem(category: TransactionCategory.education, spent: 50, limit: 100),
];

// ---------------------------------------------------------------------------
// Category breakdown (for analytics spending-by-category)
// ---------------------------------------------------------------------------

const sampleCategoryBreakdown = [
  CategoryBreakdown('Food', 420, 0.84),
  CategoryBreakdown('Bills', 650, 1.0),
  CategoryBreakdown('Shopping', 210, 0.42),
  CategoryBreakdown('Transportation', 160, 0.32),
  CategoryBreakdown('Entertainment', 180, 0.36),
  CategoryBreakdown('Healthcare', 80, 0.16),
  CategoryBreakdown('Education', 50, 0.10),
];

// ---------------------------------------------------------------------------
// Recommendations (savings tips; typically from backend/ML)
// ---------------------------------------------------------------------------

const sampleRecommendations = [
  Recommendation(
    id: '1',
    category: 'Food',
    title: 'Reduce dining out',
    description:
        'You spent 30% more on restaurants this month compared to your average.',
    potentialSavings: 85,
  ),
  Recommendation(
    id: '2',
    category: 'Entertainment',
    title: 'Review subscriptions',
    description:
        'You have 3 subscriptions totaling \$45/mo. Consider canceling unused ones.',
    potentialSavings: 15,
  ),
  Recommendation(
    id: '3',
    category: 'Bills',
    title: 'Lower utility costs',
    description:
        'Your electric bill is higher than similar households. Try off-peak usage.',
    potentialSavings: 30,
  ),
  Recommendation(
    id: '4',
    category: 'Shopping',
    title: 'Set a shopping limit',
    description:
        'Impulse purchases added up to \$120 this month. A weekly cap could help.',
    potentialSavings: 60,
  ),
  Recommendation(
    id: '5',
    category: 'Transportation',
    title: 'Optimize commute',
    description: 'Carpooling or public transit 2 days/week could save on gas.',
    potentialSavings: 40,
  ),
];
