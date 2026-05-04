import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client client;

  ApiClient({required this.baseUrl, required this.client});

  Future<http.Response> post(String endpoint, Map<String, dynamic>? body) {
    final url = Uri.parse('$baseUrl$endpoint');

    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
  }
}