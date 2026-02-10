/// Form validation helpers.

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  if (!value.contains('@')) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateAmount(String? value) {
  if (value == null || value.isEmpty) return 'Amount is required';
  final amount = double.tryParse(value);
  if (amount == null || amount <= 0) return 'Enter a valid amount';
  return null;
}
