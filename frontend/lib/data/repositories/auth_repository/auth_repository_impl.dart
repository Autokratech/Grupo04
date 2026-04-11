import 'package:frontend/data/mappers/app_user_mapper.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/services/remote/auth_api_service.dart';
import 'package:frontend/domain/models/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl({required AuthApiService authApiService})
    : _authApiService = authApiService;

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final response = await _authApiService.register(email, password);
    return AppUserMapper.toDomain(response.user);
  }
}
