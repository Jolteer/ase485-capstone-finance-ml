import 'package:flutter/material.dart';

/// Screen that lets an existing user sign in with their email and password.
///
/// Uses a [Form] with a [GlobalKey] so the fields can be validated
/// before submission. The email and password are managed by dedicated
/// [TextEditingController]s that are disposed of when the widget is
/// removed from the tree to avoid memory leaks.
///
/// TODO: Wire up [AuthProvider.login] on submit and navigate to [HomeScreen].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Key that identifies the [Form] and allows calling `validate()`.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email text field.
  final _emailController = TextEditingController();

  /// Controller for the password text field.
  final _passwordController = TextEditingController();

  /// Dispose controllers to free resources when the screen is destroyed.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: Implement login form fields and submit logic
              const Text('Login Screen – Coming Soon'),
            ],
          ),
        ),
      ),
    );
  }
}
