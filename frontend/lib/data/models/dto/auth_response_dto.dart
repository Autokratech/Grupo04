import 'package:frontend/data/models/dto/app_user_dto.dart';

class AuthResponseDto {
  final String accessToken;
  final String tokenType;
  final AppUserDto user;

  const AuthResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseDto.fromMap(Map<String, dynamic> map) {
    return AuthResponseDto(
      accessToken: map['access_token'] as String,
      tokenType: map['token_type'] as String,
      user: AppUserDto.fromMap(map['user'] as Map<String, dynamic>),
    );
  }
}