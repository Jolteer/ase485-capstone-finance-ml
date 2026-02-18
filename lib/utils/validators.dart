/// Reusable form-field validators for use with [TextFormField.validator].
///
/// Each method returns `null` when valid, or an error-message string when
/// the value fails validation. This convention is expected by Flutter’s
/// [Form] / [TextFormField] API.
class Validators {
  /// Private constructor prevents instantiation.
  Validators._();

  /// Validate that [value] is a non-empty, well-formed email address.
  /// Uses a basic regex that checks for `local@domain.tld`.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Validate that [value] is a non-empty password of at least 8 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  /// Generic required-field validator.
  /// [field] is the human-readable field name shown in the error message.
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  /// Validate that [value] is a positive numeric dollar amount.
  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
    return null;
  }
}
