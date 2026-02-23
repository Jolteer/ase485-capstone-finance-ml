/// Form field validators that return null on success or an error string on failure.
class Validators {
  Validators._();

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[\w\-\.]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates password length (min 8 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates a positive numeric amount.
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }
}
