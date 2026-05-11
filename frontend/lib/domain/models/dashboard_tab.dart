class DashboardTab {
  final String id;
  final int position;
  final String name;

  const DashboardTab({
    required this.id,
    required this.position,
    required this.name,
  });

  DashboardTab copyWith({int? position, String? name}) {
    return DashboardTab(
      id: id,
      position: position ?? this.position,
      name: name ?? this.name,
    );
  }
}
