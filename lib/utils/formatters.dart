/// Currency and date formatting helpers.

String formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

String formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
