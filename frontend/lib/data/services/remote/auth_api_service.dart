import 'dart:convert';
import 'package:frontend/data/models/dto/auth_response_dto.dart';
import 'package:frontend/data/services/remote/api_client.dart';

class AuthApiService {
  static const String _registerEndpoint = '/api/auth/register';
  static const String _loginEndpoint = '/api/auth/login';
  final ApiClient apiClient;

  AuthApiService({required this.apiClient});

  Future<AuthResponseDto> register(String email, String password) async {
    final response = await apiClient.post(_registerEndpoint, {
      'email': email,
      'password': password,
    }, authenticated: false);

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseMap =
          jsonDecode(response.body) as Map<String, dynamic>;

      return AuthResponseDto.fromMap(responseMap);
    }

    throw Exception(
      'Failed to register user: Status code ${response.statusCode}',
    );
  }

  Future<AuthResponseDto> login(String email, String password) async {
    final response = await apiClient.post(_loginEndpoint, {
      'email': email,
      'password': password,
    }, authenticated: false);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseMap =
          jsonDecode(response.body) as Map<String, dynamic>;

      return AuthResponseDto.fromMap(responseMap);
    }

    throw Exception('Failed to login user: Status code ${response.statusCode}');
  }
}
