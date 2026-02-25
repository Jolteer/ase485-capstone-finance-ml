import 'package:http/http.dart' as http;
import 'package:ase485_capstone_finance_ml/config/constants.dart';

/// Central HTTP client for all API communication.
///
/// Wraps [http.Client] and prepends [AppConstants.apiBaseUrl] to requests.
/// Will handle auth token injection and response error mapping once
/// authentication is implemented.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Base URL sourced from build-time environment variable.
  String get baseUrl => AppConstants.apiBaseUrl;

  /// Releases the underlying HTTP client resources.
  void dispose() => _client.close();

  // TODO: add get / post / put / delete helpers
}
