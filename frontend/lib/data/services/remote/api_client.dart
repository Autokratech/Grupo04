import 'dart:convert';
import 'package:frontend/data/services/local/session_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client client;
  final SessionStorageService? sessionStorageService;

  ApiClient({
    required this.baseUrl,
    required this.client,
    this.sessionStorageService,
  });

  Future<http.Response> get(
      String endpoint, {
        bool authenticated = true,
      }) {
    final url = Uri.parse('$baseUrl$endpoint');

    return client.get(
      url,
      headers: _buildHeaders(authenticated: authenticated),
    );
  }

  Future<http.Response> post(
      String endpoint,
      Map<String, dynamic>? body, {
        bool authenticated = true,
      }) {
    final url = Uri.parse('$baseUrl$endpoint');

    return client.post(
      url,
      headers: _buildHeaders(authenticated: authenticated),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Map<String, String> _buildHeaders({required bool authenticated}) {
  final headers = <String, String>{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  };

  if (!authenticated) return headers;

  final accessToken = sessionStorageService?.accessToken;
  final tokenType = sessionStorageService?.tokenType;

  if (accessToken == null || accessToken.isEmpty) {
  return headers;
  }

  headers['Authorization'] = '${_normalizeTokenType(tokenType)} $accessToken';

  return headers;
  }

  String _normalizeTokenType(String? tokenType) {
    final value = tokenType?.trim();

    if (value == null || value.isEmpty) {
      return 'Bearer';
    }

    if (value.toLowerCase() == 'bearer') {
      return 'Bearer';
    }

    return value;
  }
}
