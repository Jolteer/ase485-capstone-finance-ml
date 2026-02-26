import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/data/sample_data.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';
import 'package:ase485_capstone_finance_ml/widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ), // TODO: implement filter
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ), // TODO: implement search
        ],
      ),
      body: Column(
        children: [
          const _MonthSelector(),
          const _CategoryChips(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sampleTransactions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) =>
                  TransactionTile(transaction: sampleTransactions[index]),
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
  const _MonthSelector();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
  const _CategoryChips();

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
