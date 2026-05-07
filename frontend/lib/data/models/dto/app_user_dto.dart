class AppUserDto {
  final String id;
  final String email;
  final int roleId;
  final bool active;
  final DateTime createdAt;

  const AppUserDto({
    required this.id,
    required this.email,
    required this.roleId,
    required this.active,
    required this.createdAt,
  });

  factory AppUserDto.fromMap(Map<String, dynamic> map) {
    return AppUserDto(
      id: map['id'] as String,
      email: map['email'] as String,
      roleId: map['role_id'] as int,
      active: map['active'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}