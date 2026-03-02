import 'package:ase485_capstone_finance_ml/models/budget_item.dart';
import 'package:ase485_capstone_finance_ml/models/category_breakdown.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';

export 'package:ase485_capstone_finance_ml/models/budget_item.dart';
export 'package:ase485_capstone_finance_ml/models/category_breakdown.dart';

// ---------------------------------------------------------------------------
// Shared sample data used across screens until real provider/service
// integration replaces it.
// ---------------------------------------------------------------------------

// -- Transactions -----------------------------------------------------------

final sampleTransactions = [
  Transaction(
    id: '1',
    userId: 'demo',
    amount: -85.40,
    category: 'Food',
    description: 'Grocery Store',
    date: DateTime(2026, 2, 22),
  ),
  Transaction(
    id: '2',
    userId: 'demo',
    amount: -120.00,
    category: 'Bills',
    description: 'Electric Bill',
    date: DateTime(2026, 2, 20),
  ),
  Transaction(
    id: '3',
    userId: 'demo',
    amount: 3200.00,
    category: 'Other',
    description: 'Salary Deposit',
    date: DateTime(2026, 2, 15),
  ),
  Transaction(
    id: '4',
    userId: 'demo',
    amount: -15.99,
    category: 'Entertainment',
    description: 'Netflix',
    date: DateTime(2026, 2, 14),
  ),
  Transaction(
    id: '5',
    userId: 'demo',
    amount: -45.00,
    category: 'Transportation',
    description: 'Gas Station',
    date: DateTime(2026, 2, 13),
  ),
  Transaction(
    id: '6',
    userId: 'demo',
    amount: -67.30,
    category: 'Shopping',
    description: 'Amazon Order',
    date: DateTime(2026, 2, 12),
  ),
  Transaction(
    id: '7',
    userId: 'demo',
    amount: -24.50,
    category: 'Healthcare',
    description: 'Pharmacy',
    date: DateTime(2026, 2, 10),
  ),
  Transaction(
    id: '8',
    userId: 'demo',
    amount: -49.99,
    category: 'Education',
    description: 'Online Course',
    date: DateTime(2026, 2, 8),
  ),
];

/// First 5 transactions for the home dashboard "recent" view.
final recentTransactions = sampleTransactions.take(5).toList();

// -- Goals ------------------------------------------------------------------

final sampleGoals = [
  Goal(
    id: '1',
    userId: 'demo',
    description: 'Vacation Fund',
    progress: 1800,
    targetAmount: 3000,
    targetDate: DateTime(2026, 6),
  ),
  Goal(
    id: '2',
    userId: 'demo',
    description: 'Down Payment',
    progress: 12000,
    targetAmount: 50000,
    targetDate: DateTime(2027, 12),
  ),
  Goal(
    id: '3',
    userId: 'demo',
    description: 'Emergency Fund',
    progress: 5000,
    targetAmount: 5000,
    targetDate: DateTime(2026, 1),
  ),
  Goal(
    id: '4',
    userId: 'demo',
    description: 'New Car',
    progress: 3200,
    targetAmount: 15000,
    targetDate: DateTime(2027, 3),
  ),
];

// -- Budget items -----------------------------------------------------------

const sampleBudgetItems = [
  BudgetItem('Food', 420, 500),
  BudgetItem('Entertainment', 180, 200),
  BudgetItem('Bills', 650, 600),
  BudgetItem('Shopping', 210, 300),
  BudgetItem('Transportation', 160, 200),
  BudgetItem('Healthcare', 80, 150),
  BudgetItem('Education', 50, 100),
];

// -- Category breakdown (analytics) -----------------------------------------

const sampleCategoryBreakdown = [
  CategoryBreakdown('Food', 420, 0.84),
  CategoryBreakdown('Bills', 650, 1.0),
  CategoryBreakdown('Shopping', 210, 0.42),
  CategoryBreakdown('Transportation', 160, 0.32),
  CategoryBreakdown('Entertainment', 180, 0.36),
  CategoryBreakdown('Healthcare', 80, 0.16),
  CategoryBreakdown('Education', 50, 0.10),
];

// -- Recommendations --------------------------------------------------------

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
