import 'package:intl/intl.dart';

/// Helpers for displaying currency, dates, and percentages.
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat.yMMMd(); // e.g. Feb 18, 2026

  static final _percentFormat = NumberFormat.percentPattern();

  /// Format a number as USD currency, e.g. \$1,234.56
  static String currency(double value) => _currencyFormat.format(value);

  /// Format a DateTime as a readable date, e.g. Feb 18, 2026
  static String date(DateTime value) => _dateFormat.format(value);

  /// Format a fraction (0.0–1.0) as a percentage, e.g. 25%
  static String percentage(double value) => _percentFormat.format(value);
}
