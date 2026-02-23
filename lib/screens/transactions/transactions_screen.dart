import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/config/routes.dart';
import 'package:ase485_capstone_finance_ml/utils/categories.dart';

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
          // Month selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                Text(
                  'February 2026',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Category chips
          SizedBox(
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
          ),
          const SizedBox(height: 8),
          // Transaction list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sampleItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = _sampleItems[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      item.icon,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(item.description),
                  subtitle: Text('${item.category}  ·  ${item.date}'),
                  trailing: Text(
                    item.amount,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: item.isExpense
                          ? theme.colorScheme.error
                          : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
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

class _TxItem {
  final IconData icon;
  final String description;
  final String category;
  final String date;
  final String amount;
  final bool isExpense;
  const _TxItem(
    this.icon,
    this.description,
    this.category,
    this.date,
    this.amount,
    this.isExpense,
  );
}

const _sampleItems = [
  _TxItem(
    Icons.restaurant,
    'Grocery Store',
    'Food',
    'Feb 22',
    '-\$85.40',
    true,
  ),
  _TxItem(
    Icons.electric_bolt,
    'Electric Bill',
    'Bills',
    'Feb 20',
    '-\$120.00',
    true,
  ),
  _TxItem(
    Icons.work,
    'Salary Deposit',
    'Other',
    'Feb 15',
    '+\$3,200.00',
    false,
  ),
  _TxItem(Icons.movie, 'Netflix', 'Entertainment', 'Feb 14', '-\$15.99', true),
  _TxItem(
    Icons.directions_car,
    'Gas Station',
    'Transportation',
    'Feb 13',
    '-\$45.00',
    true,
  ),
  _TxItem(
    Icons.shopping_bag,
    'Amazon Order',
    'Shopping',
    'Feb 12',
    '-\$67.30',
    true,
  ),
  _TxItem(
    Icons.local_hospital,
    'Pharmacy',
    'Healthcare',
    'Feb 10',
    '-\$24.50',
    true,
  ),
  _TxItem(
    Icons.school,
    'Online Course',
    'Education',
    'Feb 8',
    '-\$49.99',
    true,
  ),
];
