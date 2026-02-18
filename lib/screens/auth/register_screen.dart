import 'package:flutter/material.dart';

/// Screen that lets a new user create an account.
///
/// Collects name, email, and password via a validated [Form].
/// Each field has its own [TextEditingController] that is properly
/// disposed of when the widget leaves the tree.
///
/// TODO: Wire up [AuthProvider.register] on submit, then navigate to
///       [HomeScreen].
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// Key that identifies the [Form] and allows calling `validate()`.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the full-name text field.
  final _nameController = TextEditingController();

  /// Controller for the email text field.
  final _emailController = TextEditingController();

  /// Controller for the password text field.
  final _passwordController = TextEditingController();

  /// Dispose controllers to free resources when the screen is destroyed.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: Implement registration form fields and submit logic
              const Text('Register Screen – Coming Soon'),
            ],
          ),
        ),
      ),
    );
  }
}
