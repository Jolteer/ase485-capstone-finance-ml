/// App-wide constants: API base URL and shared border radii.
///
/// Spacing constants live in `config/spacing.dart` (use [AppSpacing]); this
/// module is intentionally narrow so the two don't drift. [apiBaseUrl] is set
/// at build time via ``--dart-define=API_BASE_URL=...``.
library;

class AppConstants {
  AppConstants._();

  /// Backend API root. Override at build time, e.g.:
  /// ``flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1``.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// Extra-small border radius (4px).
  static const double radiusXs = 4;

  /// Small border radius (6px).
  static const double radiusSm = 6;

  /// Medium border radius (8px).
  static const double radiusMd = 8;

  /// Large border radius (12px).
  static const double radiusLg = 12;

  /// Extra-large border radius (16px).
  static const double radiusXl = 16;
}
