/// Application-wide constants for configuration and spacing.
/// 
/// This class provides centralized access to app-wide constants including
/// API configuration and standardized spacing values for consistent UI layout.
class AppConstants {
  /// Private constructor to prevent instantiation.
  AppConstants._();

  /// Base URL for the backend API.
  /// 
  /// Can be configured at build time using the API_BASE_URL environment variable.
  /// Defaults to 'http://localhost:8000/api/v1' for local development.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// Extra small spacing (4.0 logical pixels).
  /// 
  /// Used for minimal spacing between closely related UI elements.
  static const double spacingXs = 4;
  
  /// Small spacing (8.0 logical pixels).
  /// 
  /// Used for compact layouts and tight element grouping.
  static const double spacingSm = 8;
  
  /// Medium spacing (16.0 logical pixels).
  /// 
  /// Default spacing for most UI elements and standard margins.
  static const double spacingMd = 16;
  
  /// Large spacing (24.0 logical pixels).
  /// 
  /// Used for section separation and breathing room between major components.
  static const double spacingLg = 24;
  
  /// Extra large spacing (32.0 logical pixels).
  /// 
  /// Used for major section breaks and top-level layout spacing.
  static const double spacingXl = 32;
}
