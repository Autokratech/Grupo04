import 'package:frontend/domain/models/user_role.dart';

class AppUser {
  final String id;
  final String email;
  final UserRole role;
  final bool active;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.active
  });
}
