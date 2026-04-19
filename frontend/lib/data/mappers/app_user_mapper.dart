import 'package:frontend/data/models/dto/app_user_dto.dart';
import 'package:frontend/domain/models/app_user.dart';
import 'package:frontend/domain/models/user_role.dart';

class AppUserMapper {
  AppUserMapper._();

  static AppUser toDomain(AppUserDto dto) {
    return AppUser(
      id: dto.id,
      email: dto.email,
      role: _mapRole(dto.roleId),
      active: dto.active,
    );
  }

  static UserRole _mapRole(int roleId) {
    switch (roleId) {
      case 1:
        return UserRole.superadmin;
      case 2:
        return UserRole.admin;
      case 3:
        return UserRole.user;
      case 4:
        return UserRole.guest;
      default:
        throw Exception('Invalid role ID: $roleId');
    }
  }
}
