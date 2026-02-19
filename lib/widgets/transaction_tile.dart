import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String description;
  final String category;
  final double amount;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.description,
    required this.category,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(description),
      subtitle: Text(category),
    );
  }
}
