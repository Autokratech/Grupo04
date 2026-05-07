class DashboardTabDto {
  final String id;
  final int? index;
  final String name;

  const DashboardTabDto({
    required this.id,
    required this.index,
    required this.name,
  });

  factory DashboardTabDto.fromMap(Map<String, dynamic> map) {
    return DashboardTabDto(
      id: map['tab_id']?.toString() ?? '',
      index: _parseInt(map['tab_index']),
      name: map['tab_name']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }
}