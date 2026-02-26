import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(symbol: '\$');
  static final _dateFormat = DateFormat.yMMMd();
  static final _percentFormat = NumberFormat.percentPattern();

  static String currency(double value) => _currencyFormat.format(value);
  static String date(DateTime value) => _dateFormat.format(value);
  static String percent(double value) => _percentFormat.format(value);
}
