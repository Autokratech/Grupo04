import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/mappers/app_user_mapper.dart';
import 'package:frontend/data/models/dto/auth_dtos/app_user_dto.dart';
import 'package:frontend/domain/models/user_role.dart';

void main() {
  group('AppUserMapper.toDomain', () {
    test('convierte correctamente un usuario superadmin', () {
      final dto = AppUserDto(
        id: 'user-1',
        email: 'superadmin@test.com',
        roleId: 1,
        active: true,
        createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
      );

      final user = AppUserMapper.toDomain(dto);

      expect(user.id, 'user-1');
      expect(user.email, 'superadmin@test.com');
      expect(user.role, UserRole.superadmin);
      expect(user.active, isTrue);
    });

    test('convierte correctamente los roles válidos', () {
      final testCases = {
        1: UserRole.superadmin,
        2: UserRole.admin,
        3: UserRole.user,
        4: UserRole.guest,
      };

      for (final entry in testCases.entries) {
        final dto = AppUserDto(
          id: 'user-${entry.key}',
          email: 'user${entry.key}@test.com',
          roleId: entry.key,
          active: true,
          createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
        );

        final user = AppUserMapper.toDomain(dto);

        expect(user.role, entry.value);
      }
    });

    test('mantiene el estado active del usuario', () {
      final dto = AppUserDto(
        id: 'user-1',
        email: 'inactive@test.com',
        roleId: 3,
        active: false,
        createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
      );

      final user = AppUserMapper.toDomain(dto);

      expect(user.active, isFalse);
    });

    test('lanza excepción si el roleId no es válido', () {
      final dto = AppUserDto(
        id: 'user-1',
        email: 'invalid@test.com',
        roleId: 99,
        active: true,
        createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
      );

      expect(
            () => AppUserMapper.toDomain(dto),
        throwsException,
      );
    });
  });
}