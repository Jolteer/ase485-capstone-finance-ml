/// Form validation helpers for login, register, and transaction forms.
///
/// Return `null` when valid, or an error message string. Use with [FormFieldValidator]
/// (e.g. [TextFormField.validator]) or call directly.
import 'package:flutter/widgets.dart';

/// Static validators for required fields, email, password, and amount.
class Validators {
  Validators._();

  /// Regex for basic email validation (local@domain.tld).
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  /// Generic non-empty check with a custom field [name]. Returns a [FormFieldValidator<String>].
  static FormFieldValidator<String> required(String name) {
    return (value) =>
        (value == null || value.isEmpty) ? '$name is required' : null;
  }

  /// Validates email: non-empty and regex; returns error message or null.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Validates password: non-empty and at least 8 characters; returns error message or null.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates amount: non-empty and parseable as double; returns error message or null.
  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }
}
