import 'package:frontend/data/mappers/app_user_mapper.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/services/local/storage/session_storage_service.dart';
import 'package:frontend/data/services/remote/auth_api_service.dart';
import 'package:frontend/domain/models/app_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;
  final SessionStorageService _sessionStorageService;

  AuthRepositoryImpl({
    required AuthApiService authApiService,
    required SessionStorageService sessionStorageService,
  }) : _authApiService = authApiService,
       _sessionStorageService = sessionStorageService;

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final response = await _authApiService.register(email, password);

    await _sessionStorageService.saveSession(
      accessToken: response.accessToken,
      tokenType: response.tokenType,
      userId: response.user.id,
    );

    return AppUserMapper.toDomain(response.user);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApiService.login(email, password);

    await _sessionStorageService.saveSession(
      accessToken: response.accessToken,
      tokenType: response.tokenType,
      userId: response.user.id,
    );

    return AppUserMapper.toDomain(response.user);
  }

  @override
  Future<void> logout() async {
    await _sessionStorageService.clearSession();
  }
}
