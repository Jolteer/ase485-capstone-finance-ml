import 'package:http/http.dart' as http;
import 'package:ase485_capstone_finance_ml/config/constants.dart';

/// Central HTTP client for all API communication.
///
/// Wraps [http.Client] and provides a consistent interface for making
/// HTTP requests to the backend API. Prepends [AppConstants.apiBaseUrl]
/// to all requests and will handle authentication token injection and
/// response error mapping once authentication is implemented.
class ApiClient {
  /// The underlying HTTP client used for network requests.
  final http.Client _client;

  /// Creates an [ApiClient] instance.
  /// 
  /// Optionally accepts a custom [client] for testing purposes.
  /// If not provided, creates a new [http.Client] instance.
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Returns the API base URL.
  /// 
  /// Sourced from the build-time environment variable defined in [AppConstants].
  String get baseUrl => AppConstants.apiBaseUrl;

  /// Releases the underlying HTTP client resources.
  /// 
  /// Should be called when the client is no longer needed to free resources.
  void dispose() => _client.close();

  /// Helper method for GET requests.
  /// 
  /// Will be implemented to handle authentication headers and error responses.
  // TODO: add get / post / put / delete helpers
}
