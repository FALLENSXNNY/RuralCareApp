// API client foundation — HTTP abstraction for future backend integration
// The backend does NOT exist yet. This provides the abstraction layer
// so Phase 2+ can add real API calls cleanly.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../error/app_exception.dart';

/// HTTP methods supported by the API client.
enum ApiMethod { get, post, put, patch, delete }

/// Response wrapper for API calls.
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    required this.statusCode,
    required this.isSuccess,
  });
}

/// Base API client — handles HTTP requests, error mapping, and JSON parsing.
/// This is a foundation only. Real endpoints will be added in Phase 2+.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Performs an HTTP request and returns a typed response.
  /// Throws [AppException] on network/server errors.
  Future<ApiResponse<Map<String, dynamic>>> request(
    String path, {
    ApiMethod method = ApiMethod.get,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    String? authToken,
  }) async {
    String normalizedPath = path;
    if (_baseUrl.endsWith('/api/v1') && normalizedPath.startsWith('/api/')) {
      normalizedPath = normalizedPath.replaceFirst('/api/', '/');
    }
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
      ...?headers,
    };

    try {
      http.Response response;

      switch (method) {
        case ApiMethod.get:
          response = await _client.get(uri, headers: requestHeaders);
        case ApiMethod.post:
          response = await _client.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        case ApiMethod.put:
          response = await _client.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        case ApiMethod.patch:
          response = await _client.patch(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
        case ApiMethod.delete:
          response = await _client.delete(uri, headers: requestHeaders);
      }

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      if (response.body.isEmpty) {
        return ApiResponse<Map<String, dynamic>>(
          statusCode: response.statusCode,
          isSuccess: isSuccess,
        );
      }

      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};

      return ApiResponse<Map<String, dynamic>>(
        data: data,
        statusCode: response.statusCode,
        isSuccess: isSuccess,
      );
    } on http.ClientException catch (e) {
      throw AppException.network(e.message, e);
    } on FormatException catch (e) {
      throw AppException.server('Invalid response format', e);
    } catch (e) {
      throw AppException.unknown(e.toString(), e);
    }
  }

  void dispose() {
    _client.close();
  }
}
