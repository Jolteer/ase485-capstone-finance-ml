import 'package:ase485_capstone_finance_ml/models/budget.dart';
import 'package:ase485_capstone_finance_ml/models/goal.dart';
import 'package:ase485_capstone_finance_ml/models/recommendation.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/models/user.dart';

/// Toggle between mock and real API.
/// Set to `false` once the FastAPI backend is running.
bool useMockApi = true;

/// Provides canned sample data so the Flutter app can run without a backend.
class MockApiClient {
  MockApiClient._();

  // ── Auth ──────────────────────────────────────────────────────────────

  static const _mockToken = 'mock-jwt-token-abc123';

  /// Simulate login — always succeeds with the demo user.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    await _delay();
    return {'access_token': _mockToken, 'user': mockUser.toJson()};
  }

  /// Simulate registration — returns a token and a user with the given name/email.
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    await _delay();
    return {
      'access_token': _mockToken,
      'user': mockUser.copyWith(email: email, name: name).toJson(),
    };
  }

  /// Return the demo user profile.
  static Future<User> getMe() async {
    await _delay();
    return mockUser;
  }

  // ── Transactions ──────────────────────────────────────────────────────

  /// Return all sample transactions.
  static Future<List<Transaction>> getTransactions() async {
    await _delay();
    return List.unmodifiable(mockTransactions);
  }

  /// Create a transaction in the mock list and return it.
  static Future<Transaction> addTransaction({
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    await _delay();
    final t = Transaction(
      id: 't${mockTransactions.length + 1}',
      userId: mockUser.id,
      amount: amount,
      category: category,
      description: description,
      date: date,
    );
    mockTransactions.add(t);
    return t;
  }

  // ── Budgets ───────────────────────────────────────────────────────────

  /// Return all sample budgets.
  static Future<List<Budget>> getBudgets() async {
    await _delay();
    return List.unmodifiable(mockBudgets);
  }

  /// Create a budget in the mock list and return it.
  static Future<Budget> addBudget({
    required String category,
    required double limitAmount,
    required String period,
  }) async {
    await _delay();
    final b = Budget(
      id: 'b${mockBudgets.length + 1}',
      userId: mockUser.id,
      category: category,
      limitAmount: limitAmount,
      period: period,
      createdAt: DateTime.now(),
    );
    mockBudgets.add(b);
    return b;
  }

  // ── Goals ─────────────────────────────────────────────────────────────

  /// Return all sample goals.
  static Future<List<Goal>> getGoals() async {
    await _delay();
    return List.unmodifiable(mockGoals);
  }

  /// Create a goal in the mock list and return it.
  static Future<Goal> addGoal({
    required double targetAmount,
    required DateTime targetDate,
    required String description,
  }) async {
    await _delay();
    final g = Goal(
      id: 'g${mockGoals.length + 1}',
      userId: mockUser.id,
      targetAmount: targetAmount,
      targetDate: targetDate,
      description: description,
      progress: 0,
    );
    mockGoals.add(g);
    return g;
  }

  // ── Recommendations ───────────────────────────────────────────────────

  /// Return all sample ML recommendations.
  static Future<List<Recommendation>> getRecommendations() async {
    await _delay();
    return List.unmodifiable(mockRecommendations);
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  /// Simulate network latency.
  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));

  // ── Sample data ───────────────────────────────────────────────────────

  static final mockUser = User(
    id: 'u1',
    email: 'demo@smartspend.com',
    name: 'Demo User',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  static final mockTransactions = <Transaction>[
    Transaction(
      id: 't1',
      userId: 'u1',
      amount: 12.50,
      category: 'Food',
      description: 'Coffee & bagel',
      date: DateTime.utc(2026, 2, 15),
    ),
    Transaction(
      id: 't2',
      userId: 'u1',
      amount: 65.00,
      category: 'Shopping',
      description: 'New headphones',
      date: DateTime.utc(2026, 2, 14),
    ),
    Transaction(
      id: 't3',
      userId: 'u1',
      amount: 120.00,
      category: 'Bills',
      description: 'Electric bill',
      date: DateTime.utc(2026, 2, 10),
    ),
    Transaction(
      id: 't4',
      userId: 'u1',
      amount: 45.00,
      category: 'Transportation',
      description: 'Gas fill-up',
      date: DateTime.utc(2026, 2, 8),
    ),
    Transaction(
      id: 't5',
      userId: 'u1',
      amount: 200.00,
      category: 'Entertainment',
      description: 'Concert tickets',
      date: DateTime.utc(2026, 2, 5),
    ),
    Transaction(
      id: 't6',
      userId: 'u1',
      amount: 35.00,
      category: 'Healthcare',
      description: 'Pharmacy',
      date: DateTime.utc(2026, 2, 3),
    ),
    Transaction(
      id: 't7',
      userId: 'u1',
      amount: 89.99,
      category: 'Education',
      description: 'Online course',
      date: DateTime.utc(2026, 2, 1),
    ),
    Transaction(
      id: 't8',
      userId: 'u1',
      amount: 22.00,
      category: 'Food',
      description: 'Lunch delivery',
      date: DateTime.utc(2026, 1, 28),
    ),
  ];

  static final mockBudgets = <Budget>[
    Budget(
      id: 'b1',
      userId: 'u1',
      category: 'Food',
      limitAmount: 400.0,
      period: 'monthly',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    Budget(
      id: 'b2',
      userId: 'u1',
      category: 'Entertainment',
      limitAmount: 200.0,
      period: 'monthly',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    Budget(
      id: 'b3',
      userId: 'u1',
      category: 'Bills',
      limitAmount: 500.0,
      period: 'monthly',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    Budget(
      id: 'b4',
      userId: 'u1',
      category: 'Shopping',
      limitAmount: 150.0,
      period: 'monthly',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
    Budget(
      id: 'b5',
      userId: 'u1',
      category: 'Transportation',
      limitAmount: 250.0,
      period: 'monthly',
      createdAt: DateTime.utc(2026, 1, 1),
    ),
  ];

  static final mockGoals = <Goal>[
    Goal(
      id: 'g1',
      userId: 'u1',
      targetAmount: 1000.0,
      targetDate: DateTime.utc(2026, 6, 30),
      description: 'Emergency fund',
      progress: 350.0,
    ),
    Goal(
      id: 'g2',
      userId: 'u1',
      targetAmount: 2500.0,
      targetDate: DateTime.utc(2026, 12, 31),
      description: 'Vacation savings',
      progress: 800.0,
    ),
    Goal(
      id: 'g3',
      userId: 'u1',
      targetAmount: 500.0,
      targetDate: DateTime.utc(2026, 4, 1),
      description: 'New laptop fund',
      progress: 500.0,
    ),
  ];

  static final mockRecommendations = <Recommendation>[
    const Recommendation(
      id: 'r1',
      category: 'Food',
      title: 'Reduce dining out',
      description:
          'You spent 40% more on food delivery this month compared to last. '
          'Cooking at home 3 more days per week could save significantly.',
      potentialSavings: 85.0,
    ),
    const Recommendation(
      id: 'r2',
      category: 'Entertainment',
      title: 'Review subscriptions',
      description:
          'You have 4 active streaming subscriptions totaling \$52/month. '
          'Consider consolidating to 2 services.',
      potentialSavings: 26.0,
    ),
    const Recommendation(
      id: 'r3',
      category: 'Transportation',
      title: 'Carpool opportunities',
      description:
          'Your weekly gas spending is above average. '
          'Carpooling twice a week could reduce fuel costs by ~30%.',
      potentialSavings: 54.0,
    ),
  ];
}
