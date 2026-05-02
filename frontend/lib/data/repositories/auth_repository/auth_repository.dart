import 'package:frontend/domain/models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> register({required String email, required String password});

  Future<AppUser> login({required String email, required String password});

  Future<void> logout();
}
