/// Persisted app settings: appearance, notifications, security, and locale.
///
/// Backed by [SharedPreferences]. Call [init] once at app startup (before the
/// first [notifyListeners]-dependent widget renders) to hydrate from disk.
/// All setters persist immediately and notify listeners so [MaterialApp.themeMode]
/// and [Formatters] stay in sync without manual coordination.
library;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:ase485_capstone_finance_ml/utils/formatters.dart';

/// Manages and persists user preferences via [SharedPreferences].
///
/// Exposes [themeMode] derived from [darkMode] for direct use in
/// [MaterialApp.themeMode]. Currency formatting is kept in sync with
/// [Formatters] so every call-site benefits without passing locale explicitly.
class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  bool _darkMode = false;
  bool _notifications = true;
  bool _biometric = false;
  String _currencyLocale = 'en_US';

  // ── Storage keys ──────────────────────────────────────────────────────────
  static const _kDarkMode = 'settings_dark_mode';
  static const _kNotifications = 'settings_notifications';
  static const _kBiometric = 'settings_biometric';
  static const _kCurrencyLocale = 'settings_currency_locale';

  // ── Getters ───────────────────────────────────────────────────────────────

  /// [ThemeMode] derived from [darkMode]; wire to [MaterialApp.themeMode].
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get biometric => _biometric;

  /// BCP-47 locale tag used for currency formatting (e.g. `"en_US"`, `"de_DE"`).
  String get currencyLocale => _currencyLocale;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Loads persisted preferences from disk.
  ///
  /// Must be awaited before the first frame that depends on persisted values
  /// (typically called in [State.initState] of the root widget). Safe to call
  /// multiple times; subsequent calls reload from disk.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _darkMode = _prefs!.getBool(_kDarkMode) ?? false;
    _notifications = _prefs!.getBool(_kNotifications) ?? true;
    _biometric = _prefs!.getBool(_kBiometric) ?? false;
    _currencyLocale = _prefs!.getString(_kCurrencyLocale) ?? 'en_US';
    Formatters.updateLocale(_currencyLocale);
    notifyListeners();
  }

  // ── Setters (persist + notify) ────────────────────────────────────────────

  /// Toggles dark/light theme and persists the choice.
  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    _darkMode = value;
    await _prefs?.setBool(_kDarkMode, value);
    notifyListeners();
  }

  /// Enables or disables push-notification preference.
  Future<void> setNotifications(bool value) async {
    if (_notifications == value) return;
    _notifications = value;
    await _prefs?.setBool(_kNotifications, value);
    notifyListeners();
  }

  /// Enables or disables biometric-login preference.
  Future<void> setBiometric(bool value) async {
    if (_biometric == value) return;
    _biometric = value;
    await _prefs?.setBool(_kBiometric, value);
    notifyListeners();
  }

  /// Updates the locale used for currency formatting.
  ///
  /// Propagates immediately to [Formatters.updateLocale] so all subsequent
  /// [Formatters.currency] calls reflect the new locale.
  Future<void> setCurrencyLocale(String locale) async {
    if (_currencyLocale == locale) return;
    _currencyLocale = locale;
    await _prefs?.setString(_kCurrencyLocale, locale);
    Formatters.updateLocale(locale);
    notifyListeners();
  }

  // ── Data management ───────────────────────────────────────────────────────

  /// Wipes all persisted settings and resets in-memory state to defaults.
  ///
  /// Does NOT clear auth data or feature-data caches — callers should combine
  /// this with [AuthProvider.logout] when implementing a full "clear data" flow.
  Future<void> clearSettings() async {
    await _prefs?.clear();
    _darkMode = false;
    _notifications = true;
    _biometric = false;
    _currencyLocale = 'en_US';
    Formatters.updateLocale('en_US');
    notifyListeners();
  }
}
