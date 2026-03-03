/// Display formatting for currency, dates, and percentages using [intl].
///
/// Use in UI (e.g. [BudgetScreen], [AnalyticsScreen]) for consistent locale-aware output.
import 'package:intl/intl.dart';

/// Static formatters for currency, date, and percent. Use for consistent UI output.
class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _dateFormat = DateFormat.yMMMd();
  static final _percentFormat = NumberFormat.percentPattern();

  /// Formats [value] as currency (e.g. \$1,234.56).
  static String currency(double value) => _currencyFormat.format(value);

  /// Formats [value] as short date (e.g. Feb 22, 2026).
  static String date(DateTime value) => _dateFormat.format(value);

  /// Formats [value] as percentage (e.g. 50%).
  static String percent(double value) => _percentFormat.format(value);
}
