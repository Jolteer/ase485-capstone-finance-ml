/// Display formatting for currency, dates, and percentages using [intl].
///
/// Currency output is locale-aware: call [updateLocale] (done automatically by
/// [SettingsProvider]) whenever the user changes their locale preference.
/// All other call-sites remain unchanged — they just call [Formatters.currency].
library;

import 'package:intl/intl.dart';

/// Static formatters for currency, date, and percent. Use for consistent UI output.
///
/// The currency formatter is rebuilt whenever [updateLocale] is called, so it
/// always reflects the active locale preference without threading the locale
/// through every widget. Date and percent formatters are locale-independent.
class Formatters {
  Formatters._();

  static String _currencyLocale = 'en_US';
  static NumberFormat _currencyFormat = NumberFormat.currency(
    locale: _currencyLocale,
  );

  static final _dateFormat = DateFormat.yMMMd();
  static final _percentFormat = NumberFormat.percentPattern();

  /// Updates the locale used by [currency] and rebuilds the internal formatter.
  ///
  /// Called by [SettingsProvider] on [init] and on every [setCurrencyLocale].
  /// The [locale] must be a valid ICU/BCP-47 locale string (e.g. `"en_US"`,
  /// `"de_DE"`, `"ja_JP"`).
  static void updateLocale(String locale) {
    if (_currencyLocale == locale) return;
    _currencyLocale = locale;
    _currencyFormat = NumberFormat.currency(locale: locale);
  }

  /// Formats [value] as currency using the active locale (e.g. \$1,234.56).
  static String currency(double value) => _currencyFormat.format(value);

  /// Formats [value] as short date (e.g. Feb 22, 2026).
  static String date(DateTime value) => _dateFormat.format(value);

  /// Formats [value] as percentage (e.g. 50%).
  static String percent(double value) => _percentFormat.format(value);

  /// Exposes the current locale string; useful for displaying the active
  /// preference in a settings UI without importing the full provider.
  static String get currentLocale => _currencyLocale;
}
