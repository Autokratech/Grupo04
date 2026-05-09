import 'dart:convert';
import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebDashboardLocalDataSource implements DashboardLocalDataSource {
  static const int _maxTabs = AppConstants.maxTabs;

  final SharedPreferences sharedPreferences;

  const WebDashboardLocalDataSource({required this.sharedPreferences});

  @override
  Future<Dashboard?> getCachedDashboard({required String dashboardId}) async {
    final rawValue = sharedPreferences.getString(_dashboardKey(dashboardId));

    if (rawValue == null) {
      return null;
    }

    final map = _decodeMap(rawValue);

    if (map == null) {
      return null;
    }

    return _dashboardFromMap(map);
  }

  @override
  Future<void> cacheDashboard(Dashboard dashboard) async {
    await sharedPreferences.setString(
      _dashboardKey(dashboard.id),
      jsonEncode(_dashboardToMap(dashboard)),
    );
  }

  @override
  Future<List<DashboardTab>> getCachedTabs({
    required String dashboardId,
  }) async {
    final rawValue = sharedPreferences.getString(_tabsKey(dashboardId));

    if (rawValue == null) {
      return [];
    }

    final list = _decodeList(rawValue);

    if (list == null) {
      return [];
    }

    final tabs =
        list
            .whereType<Map<String, dynamic>>()
            .map(_dashboardTabFromMap)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));

    return _normalizeTabs(tabs);
  }

  @override
  Future<void> cacheTabs({
    required String dashboardId,
    required List<DashboardTab> tabs,
  }) async {
    final normalizedTabs = _normalizeTabs(tabs);

    await sharedPreferences.setString(
      _tabsKey(dashboardId),
      jsonEncode(normalizedTabs.map(_dashboardTabToMap).toList()),
    );
  }

  @override
  Future<DashboardTab> createLocalTab({
    required String dashboardId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw StateError('Introduce un nombre');
    }

    final currentTabs = await getCachedTabs(dashboardId: dashboardId);

    if (currentTabs.length >= _maxTabs) {
      throw StateError('No se pueden crear más de $_maxTabs dashboards.');
    }

    final tab = DashboardTab(
      id: '${dashboardId}_local_${DateTime.now().microsecondsSinceEpoch}',
      name: normalizedName,
      position: currentTabs.length,
    );

    final updatedTabs = _normalizeTabs([...currentTabs, tab]);

    await cacheTabs(dashboardId: dashboardId, tabs: updatedTabs);

    return updatedTabs.firstWhere((item) => item.id == tab.id);
  }

  @override
  Future<DashboardTab> renameLocalTab({
    required String dashboardId,
    required String tabId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw StateError('Introduce un nombre');
    }

    final currentTabs = await getCachedTabs(dashboardId: dashboardId);

    final tabExists = currentTabs.any((tab) => tab.id == tabId);

    if (!tabExists) {
      throw StateError('El dashboard no existe');
    }

    final updatedTabs = currentTabs.map((tab) {
      if (tab.id != tabId) {
        return tab;
      }

      return tab.copyWith(name: normalizedName);
    }).toList();

    await cacheTabs(dashboardId: dashboardId, tabs: updatedTabs);

    return updatedTabs.firstWhere((tab) => tab.id == tabId);
  }

  @override
  Future<void> deleteLocalTab({
    required String dashboardId,
    required String tabId,
  }) async {
    final currentTabs = await getCachedTabs(dashboardId: dashboardId);

    if (currentTabs.length <= 1) {
      throw StateError('Debe existir al menos un dashboard');
    }

    final filteredTabs = currentTabs.where((tab) => tab.id != tabId).toList();

    if (filteredTabs.length == currentTabs.length) {
      throw StateError('El dashboard no existe');
    }

    await cacheTabs(
      dashboardId: dashboardId,
      tabs: _normalizeTabs(filteredTabs),
    );

    await sharedPreferences.remove(_widgetsKey(tabId));
  }

  @override
  Future<List<DashboardTab>> updateLocalTabOrder({
    required String dashboardId,
    required List<DashboardTab> tabs,
  }) async {
    if (tabs.isEmpty) {
      throw StateError('Debe existir al menos un dashboard');
    }

    final currentTabs = await getCachedTabs(dashboardId: dashboardId);

    final existingIds = currentTabs.map((tab) => tab.id).toSet();
    final incomingIds = tabs.map((tab) => tab.id).toSet();

    final hasSameLength = currentTabs.length == tabs.length;
    final hasNoDuplicateIncomingIds = incomingIds.length == tabs.length;
    final hasSameIds =
        existingIds.containsAll(incomingIds) &&
        incomingIds.containsAll(existingIds);

    if (!hasSameLength || !hasNoDuplicateIncomingIds || !hasSameIds) {
      throw StateError(
        'La lista de dashboards no coincide con el dashboard actual',
      );
    }

    final normalizedTabs = _normalizeTabs(tabs);

    await cacheTabs(dashboardId: dashboardId, tabs: normalizedTabs);

    return normalizedTabs;
  }

  @override
  Future<List<DashboardWidgetItem>> getCachedTabWidgets({
    required String tabId,
  }) async {
    final rawValue = sharedPreferences.getString(_widgetsKey(tabId));

    if (rawValue == null) {
      return [];
    }

    final list = _decodeList(rawValue);

    if (list == null) {
      return [];
    }

    final widgets =
        list
            .whereType<Map<String, dynamic>>()
            .map(_dashboardWidgetFromMap)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));

    return _normalizeWidgets(widgets);
  }

  @override
  Future<void> cacheTabWidgets({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  }) async {
    final normalizedWidgets = _normalizeWidgets(widgets);

    await sharedPreferences.setString(
      _widgetsKey(tabId),
      jsonEncode(normalizedWidgets.map(_dashboardWidgetToMap).toList()),
    );
  }

  String _dashboardKey(String dashboardId) {
    return 'web_dashboard_cache_$dashboardId';
  }

  String _tabsKey(String dashboardId) {
    return 'web_dashboard_tabs_cache_$dashboardId';
  }

  String _widgetsKey(String tabId) {
    return 'web_dashboard_widgets_cache_$tabId';
  }

  Map<String, dynamic>? _decodeMap(String value) {
    final decodedValue = jsonDecode(value);

    if (decodedValue is Map<String, dynamic>) {
      return decodedValue;
    }

    return null;
  }

  List<dynamic>? _decodeList(String value) {
    final decodedValue = jsonDecode(value);

    if (decodedValue is List<dynamic>) {
      return decodedValue;
    }

    return null;
  }

  Dashboard _dashboardFromMap(Map<String, dynamic> map) {
    return Dashboard(
      id: map['id'] as String,
      theme: map['theme'] as String?,
      language: map['language'] as String?,
    );
  }

  Map<String, dynamic> _dashboardToMap(Dashboard dashboard) {
    return {
      'id': dashboard.id,
      'theme': dashboard.theme,
      'language': dashboard.language,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  DashboardTab _dashboardTabFromMap(Map<String, dynamic> map) {
    return DashboardTab(
      id: map['id'] as String,
      name: map['name'] as String,
      position: map['position'] as int,
    );
  }

  Map<String, dynamic> _dashboardTabToMap(DashboardTab tab) {
    return {
      'id': tab.id,
      'name': tab.name,
      'position': tab.position,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  DashboardWidgetItem _dashboardWidgetFromMap(Map<String, dynamic> map) {
    return DashboardWidgetItem(
      id: map['id'] as String,
      title: map['title'] as String,
      type: _widgetTypeFromName(map['type']),
      status: _widgetStatusFromName(map['status']),
      primaryValue: map['primary_value'] as String,
      description: map['description'] as String?,
      position: map['position'] as int,
    );
  }

  Map<String, dynamic> _dashboardWidgetToMap(DashboardWidgetItem widget) {
    return {
      'id': widget.id,
      'title': widget.title,
      'type': widget.type.name,
      'status': widget.status.name,
      'primary_value': widget.primaryValue,
      'description': widget.description,
      'position': widget.position,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  List<DashboardTab> _normalizeTabs(List<DashboardTab> tabs) {
    final sortedTabs = [...tabs]
      ..sort((a, b) => a.position.compareTo(b.position));

    return [
      for (var index = 0; index < sortedTabs.length; index++)
        sortedTabs[index].copyWith(position: index),
    ];
  }

  List<DashboardWidgetItem> _normalizeWidgets(
    List<DashboardWidgetItem> widgets,
  ) {
    final sortedWidgets = [...widgets]
      ..sort((a, b) => a.position.compareTo(b.position));

    return [
      for (var index = 0; index < sortedWidgets.length; index++)
        sortedWidgets[index].copyWith(position: index),
    ];
  }

  WidgetType _widgetTypeFromName(Object? value) {
    final name = value?.toString();

    for (final type in WidgetType.values) {
      if (type.name == name) {
        return type;
      }
    }

    return WidgetType.status;
  }

  WidgetStatus _widgetStatusFromName(Object? value) {
    final name = value?.toString();

    for (final status in WidgetStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return WidgetStatus.inactive;
  }
}
