/// App-wide constants: API base URL, spacing, radius, animation duration, pagination.
///
/// [apiBaseUrl] is set at build time via `--dart-define=API_BASE_URL=...`.
/// Use [AppConstants] instead of magic numbers for layout and behavior.
class AppConstants {
  AppConstants._();

  /// API base URL; set via `--dart-define=API_BASE_URL=...` or uses default.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// Extra-small spacing (4px).
  static const double spacingXs = 4;

  /// Small spacing (8px).
  static const double spacingSm = 8;

  /// Medium spacing (16px).
  static const double spacingMd = 16;

  /// Large spacing (24px).
  static const double spacingLg = 24;

  /// Extra-large spacing (32px).
  static const double spacingXl = 32;

  /// Small border radius (6px).
  static const double radiusSm = 6;

  /// Medium border radius (8px).
  static const double radiusMd = 8;

  /// Large border radius (12px).
  static const double radiusLg = 12;

  /// Extra-large border radius (16px).
  static const double radiusXl = 16;

  /// Short animation duration (200ms).
  static const Duration animFast = Duration(milliseconds: 200);

  /// Standard animation duration (300ms).
  static const Duration animNormal = Duration(milliseconds: 300);

  /// Default number of items per page for list/pagination.
  static const int defaultPageSize = 20;
}
