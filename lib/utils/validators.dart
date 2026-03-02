/// Utility class for form field validation.
/// 
/// Provides validators for common input types including email,
/// password, and numeric amounts. Returns null if valid, or an
/// error message string if invalid.
class Validators {
  /// Private constructor to prevent instantiation.
  Validators._();

  /// Regular expression pattern for validating email addresses.
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  /// Validates an email address field.
  /// 
  /// Returns an error message if the value is empty or not a valid email format.
  /// Returns null if validation passes.
  /// 
  /// Example: `email("user@example.com")` returns `null` (valid)
  /// Example: `email("invalid")` returns "Enter a valid email"
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Validates a password field.
  /// 
  /// Returns an error message if the value is empty or less than 8 characters.
  /// Returns null if validation passes.
  /// 
  /// Example: `password("mypassword123")` returns `null` (valid)
  /// Example: `password("short")` returns "Password must be at least 8 characters"
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Validates a numeric amount field.
  /// 
  /// Returns an error message if the value is empty or not a valid number.
  /// Returns null if validation passes.
  /// 
  /// Example: `amount("123.45")` returns `null` (valid)
  /// Example: `amount("abc")` returns "Enter a valid number"
  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }
}
