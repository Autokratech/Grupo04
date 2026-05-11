class DashboardDto {
  final String id;
  final String? theme;
  final String? language;

  const DashboardDto({
    required this.id,
    required this.theme,
    required this.language,
  });

  factory DashboardDto.fromMap(Map<String, dynamic> map) {
    return DashboardDto(
      id: map['dashboard_id']?.toString() ?? '',
      theme: map['dashboard_theme']?.toString(),
      language: map['dashboard_language']?.toString(),
    );
  }
}
