/// Application-wide constants shared across layers (services, UI, etc.).
///
/// Values here are compile-time constants so they can be inlined by the
/// compiler and used in `const` expressions.
class AppConstants {
  AppConstants._();

  // ── API configuration ─────────────────────────────────────────────────
  /// Root URL of the FastAPI backend. Change this when pointing at
  /// staging or production servers.
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';

  /// Maximum duration to wait for any single API call before throwing
  /// a timeout exception.
  static const Duration apiTimeout = Duration(seconds: 10);

  // ── Pagination ────────────────────────────────────────────────────────
  /// Default number of records fetched per page in paginated API calls.
  static const int defaultPageSize = 20;

  // ── ML thresholds ─────────────────────────────────────────────────────
  /// Minimum confidence score (0–1) for the ML model to accept an
  /// auto-categorisation. Below this value the user is prompted to
  /// confirm or correct the category.
  static const double categorizationConfidenceThreshold = 0.80;

  /// Minimum number of actionable savings tips the ML engine must return
  /// per analysis.
  static const int minRecommendations = 3;

  // ── Budget period identifiers ─────────────────────────────────────────
  /// String values sent to / received from the API to indicate the time
  /// window a budget covers.
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';
  static const String periodYearly = 'yearly';

  // ── Local storage keys ────────────────────────────────────────────────
  /// Key under which the JWT auth token is persisted in local storage.
  static const String tokenKey = 'auth_token';

  /// Key for the cached user profile JSON blob.
  static const String userKey = 'current_user';

  /// Key for the persisted theme mode preference ('light', 'dark', 'system').
  static const String themeKey = 'theme_mode';
}
