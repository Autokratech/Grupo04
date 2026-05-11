import 'dart:convert';
import 'package:frontend/data/services/local/storage/session_storage_service.dart';
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

  Future<http.Response> get(String endpoint, {bool authenticated = true}) {
    final url = _buildUri(endpoint);

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
    final url = _buildUri(endpoint);

    return client.post(
      url,
      headers: _buildHeaders(authenticated: authenticated),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic>? body, {
    bool authenticated = true,
  }) {
    final url = _buildUri(endpoint);

    return client.put(
      url,
      headers: _buildHeaders(authenticated: authenticated),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint, {bool authenticated = true}) {
    final url = _buildUri(endpoint);

    return client.delete(
      url,
      headers: _buildHeaders(authenticated: authenticated),
    );
  }

  Future<http.StreamedResponse> getStream(
    String endpoint, {
    bool authenticated = true,
  }) {
    final url = _buildUri(endpoint);

    final request = http.Request('GET', url);

    request.headers.addAll(_buildHeaders(authenticated: authenticated));

    request.headers['Accept'] = 'text/event-stream';
    request.headers.remove('Content-Type');

    return client.send(request);
  }

  Future<Uri> getRedirectLocation(
    String endpoint, {
    bool authenticated = true,
  }) async {
    final url = _buildUri(endpoint);

    final request = http.Request('GET', url)
      ..followRedirects = false
      ..headers.addAll(_buildHeaders(authenticated: authenticated));

    final response = await client.send(request);

    final location = response.headers['location'];

    if (response.statusCode != 307 && response.statusCode != 302) {
      throw Exception(
        'Expected redirect response but got status code ${response.statusCode}',
      );
    }

    if (location == null || location.trim().isEmpty) {
      throw Exception('Redirect response does not contain Location header');
    }

    return Uri.parse(location);
  }

  Uri _buildUri(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
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
