import 'package:intl/intl.dart';

/// Utility class for formatting values for display.
/// 
/// Provides consistent formatting for currency, dates, and percentages
/// throughout the application using the intl package.
class Formatters {
  /// Private constructor to prevent instantiation.
  Formatters._();

  /// Number formatter for currency values with dollar sign.
  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  
  /// Date formatter using abbreviated month, day, and year (e.g., "Feb 22, 2026").
  static final _dateFormat = DateFormat.yMMMd();
  
  /// Number formatter for percentage values.
  static final _percentFormat = NumberFormat.percentPattern();

  /// Formats a numeric value as currency with dollar sign and decimal places.
  /// 
  /// Example: `currency(1234.56)` returns "$1,234.56"
  static String currency(double value) => _currencyFormat.format(value);
  
  /// Formats a DateTime as a readable date string.
  /// 
  /// Example: `date(DateTime(2026, 2, 22))` returns "Feb 22, 2026"
  static String date(DateTime value) => _dateFormat.format(value);
  
  /// Formats a decimal value as a percentage string.
  /// 
  /// Example: `percent(0.75)` returns "75%"
  static String percent(double value) => _percentFormat.format(value);
}
