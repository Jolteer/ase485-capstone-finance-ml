import 'package:intl/intl.dart';

/// Static helper methods for formatting currency, dates, and percentages.
///
/// Uses the `intl` package for locale-aware formatting. The private
/// constructors ensure this class is never instantiated — all members
/// are static.
class Formatters {
  /// Private constructor prevents instantiation.
  Formatters._();

  /// Formatter for dollar amounts (e.g. `$1,234.56`).
  static final _currencyFormat = NumberFormat.currency(symbol: '\$');

  /// Short date format (e.g. `Jan 5, 2025`).
  static final _dateFormat = DateFormat('MMM d, yyyy');

  /// Date + time format (e.g. `Jan 5, 2025 – 3:30 PM`).
  static final _dateTimeFormat = DateFormat('MMM d, yyyy \u2013 h:mm a');

  /// Format a [double] as a dollar string.
  static String currency(double amount) => _currencyFormat.format(amount);

  /// Format a [DateTime] as a short date string.
  static String date(DateTime dt) => _dateFormat.format(dt);

  /// Format a [DateTime] as a date + time string.
  static String dateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// Format a 0–1 [double] as a percentage string (e.g. `75.0%`).
  static String percentage(double value) =>
      '${(value * 100).toStringAsFixed(1)}%';
}
