import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_tab_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_tabs_response_dto.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';

class DashboardMapper {
  const DashboardMapper._();

  static Dashboard toDomain(DashboardDto dto) {
    return Dashboard(
      id: dto.id,
      theme: _emptyToNull(dto.theme),
      language: _emptyToNull(dto.language),
    );
  }

  static List<DashboardTab> tabsToDomain(DashboardTabsResponseDto dto) {
    final tabs = dto.tabs
        .where((tab) => tab.id.trim().isNotEmpty)
        .map(_tabToDomain)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return _normalizeTabPositions(tabs);
  }

  static DashboardTab _tabToDomain(DashboardTabDto dto) {
    return DashboardTab(
      id: dto.id,
      name: dto.name.trim().isEmpty ? 'Dashboard' : dto.name.trim(),
      position: _backendIndexToPosition(dto.index),
    );
  }

  static int _backendIndexToPosition(int? index) {
    if (index == null || index <= 1) {
      return 0;
    }

    return index - 1;
  }

  static List<DashboardTab> _normalizeTabPositions(List<DashboardTab> tabs) {
    return [
      for (var i = 0; i < tabs.length; i++)
        tabs[i].copyWith(position: i),
    ];
  }

  static String? _emptyToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }
}