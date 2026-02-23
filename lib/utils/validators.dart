class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }
}
