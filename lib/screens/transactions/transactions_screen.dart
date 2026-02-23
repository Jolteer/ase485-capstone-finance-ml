import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/models/transaction.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _MonthSelector(theme: theme),
          _CategoryChips(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sampleTransactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) =>
                  TransactionTile(transaction: _sampleTransactions[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
          Text(
            'February 2026',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: const Text('All'),
              selected: true,
              onSelected: (_) {},
            ),
          ),
          ...Categories.all.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(c),
                selected: false,
                onSelected: (_) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data (uses the real Transaction model)
// ---------------------------------------------------------------------------

final _sampleTransactions = [
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
