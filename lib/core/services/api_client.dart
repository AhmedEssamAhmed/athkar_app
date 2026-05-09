import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base API client that all service classes use to communicate
/// with the FastAPI backend.
///
/// During local development the backend runs at `localhost:8000`.
/// Change [_baseUrl] when deploying to Cloud Run or another host.
class ApiClient {
  // ── Configuration ──────────────────────────────────────────────
  // For Android emulator use `10.0.2.2` instead of `localhost`.
  // For physical device use your machine's LAN IP.
  static const String _baseUrl = 'http://localhost:8000';

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Performs a GET request and returns the decoded JSON body.
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }

  void dispose() => _client.close();
}

/// Exception thrown when the API returns a non-2xx status.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
