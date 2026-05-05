import 'dart:convert';

import 'package:frontend/data/models/dto/app_user_dto.dart';
import 'package:frontend/data/services/remote/api_client.dart';

class UserApiService {
  static const String _meEndpoint = '/api/users/me';

  final ApiClient apiClient;

  UserApiService({required this.apiClient});

  Future<AppUserDto> getCurrentUser() async {
    final response = await apiClient.get(_meEndpoint);

    if (response.statusCode == 200) {
      final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AppUserDto.fromMap(responseMap);
    }

    throw Exception('Failed to get current user');
  }
}