import 'package:flutter/material.dart';

/// Form screen for manually entering a new transaction.
///
/// Planned form fields:
/// • Amount – numeric input validated as a positive number.
/// • Category – dropdown populated from [Categories.all].
/// • Description – free-text field.
/// • Date – date picker defaulting to today.
///
/// On submit the form calls [TransactionProvider.addTransaction] and
/// pops the screen.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  /// Key used to validate all form fields before submission.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: const Column(
            children: [
              // TODO: Implement transaction input fields (amount, category, description, date)
              Text('Add Transaction – Coming Soon'),
            ],
          ),
        ),
      ),
    );
  }
}
