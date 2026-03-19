import 'package:frontend/domain/models/user_role.dart';

class AppUser {
  final int id;
  final String displayName;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
  });
}
