import 'package:frontend/data/models/dto/dashboard_tab_dto.dart';

class DashboardTabsResponseDto {
  final List<DashboardTabDto> tabs;

  const DashboardTabsResponseDto({
    required this.tabs,
  });

  factory DashboardTabsResponseDto.fromMap(Map<String, dynamic> map) {
    final rawTabs = map['tabs'];

    if (rawTabs is! List) {
      return const DashboardTabsResponseDto(tabs: []);
    }

    return DashboardTabsResponseDto(
      tabs: rawTabs
          .whereType<Map<String, dynamic>>()
          .map(DashboardTabDto.fromMap)
          .toList(),
    );
  }
}