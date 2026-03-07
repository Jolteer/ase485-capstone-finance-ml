/// Form validation helpers for login, register, and transaction forms.
///
/// Return `null` when valid, or an error message string. Use with
/// [FormFieldValidator] (e.g. [TextFormField.validator]) or call directly.
///
/// Factory validators (e.g. [Validators.required], [confirmPassword]) return a
/// [FormFieldValidator] and are used as `validator: Validators.required('Name')`.
/// Direct validators (e.g. [email], [password]) are used as `validator: Validators.email`.
library;

import 'package:flutter/widgets.dart';

/// Static validators for required fields, email, password, amount, and confirm-password.
class Validators {
  Validators._();

  /// Regex for basic email validation (local@domain.tld).
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  /// Minimum acceptable password length.
  static const int _minPasswordLength = 8;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns an error message when [value] is null or empty, otherwise null.
  /// Used internally to avoid repeating the null/empty pattern in every validator.
  static String? _checkRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Factory validators (return a FormFieldValidator)
  // ---------------------------------------------------------------------------

  /// Returns a validator that rejects null or empty input, labeling the field [name].
  ///
  /// Usage: `validator: Validators.required('Name')`
  static FormFieldValidator<String> required(String name) {
    return (value) => _checkRequired(value, name);
  }

  /// Returns a validator that checks the input matches [getPassword].
  ///
  /// [getPassword] is typically `() => _passwordController.text`.
  /// Usage: `validator: Validators.confirmPassword(() => _passwordController.text)`
  static FormFieldValidator<String> confirmPassword(
    String Function() getPassword,
  ) {
    return (value) {
      final emptyError = _checkRequired(value, 'Confirm password');
      if (emptyError != null) return emptyError;
      if (value != getPassword()) return 'Passwords do not match';
      return null;
    };
  }

  // ---------------------------------------------------------------------------
  // Direct validators (used as a FormFieldValidator reference)
  // ---------------------------------------------------------------------------

  /// Validates email: non-empty and matches a basic `local@domain.tld` pattern.
  ///
  /// Usage: `validator: Validators.email`
  static String? email(String? value) {
    final emptyError = _checkRequired(value, 'Email');
    if (emptyError != null) return emptyError;
    if (!_emailRegex.hasMatch(value!)) return 'Enter a valid email address';
    return null;
  }

  /// Validates password: non-empty and at least [_minPasswordLength] characters.
  ///
  /// Usage: `validator: Validators.password`
  static String? password(String? value) {
    final emptyError = _checkRequired(value, 'Password');
    if (emptyError != null) return emptyError;
    if (value!.length < _minPasswordLength) {
      return 'Password must be at least $_minPasswordLength characters';
    }
    return null;
  }

  /// Validates a financial amount: non-empty, parseable as a number, and positive.
  ///
  /// Zero and negative values are rejected because a transaction amount must
  /// represent a real monetary movement.
  ///
  /// Usage: `validator: Validators.amount`
  static String? amount(String? value) {
    final emptyError = _checkRequired(value, 'Amount');
    if (emptyError != null) return emptyError;
    final parsed = double.tryParse(value!);
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return 'Amount must be greater than zero';
    return null;
  }
}
