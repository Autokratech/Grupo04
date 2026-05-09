import 'package:frontend/data/fallbacks/fallback_widget_catalog.dart';
import 'package:frontend/data/mappers/dashboard_mapper.dart';
import 'package:frontend/data/mappers/dashboard_widget_mapper.dart';
import 'package:frontend/data/mappers/widget_catalog_mapper.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/dashboard_tab_dto.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/data/services/local/session_storage_service.dart';
import 'package:frontend/data/services/remote/dashboard_api_service.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/domain/models/widget_status.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final DashboardApiService apiService;
  final SessionStorageService sessionStorageService;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.apiService,
    required this.sessionStorageService,
  });

  @override
  Future<Dashboard> getDashboard() async {
    final userId = _currentUserId;

    try {
      final dashboardDto = await apiService.getUserDashboard(userId: userId);
      final remoteDashboard = DashboardMapper.toDomain(dashboardDto);

      if (remoteDashboard.id.trim().isEmpty) {
        throw StateError('El dashboard remoto no tiene id válido');
      }

      await localDataSource.cacheDashboard(remoteDashboard);

      return remoteDashboard;
    } catch (_) {
      return _getFallbackDashboard(userId);
    }
  }

  @override
  Future<List<DashboardTab>> getDashboardTabs({
    required String dashboardId,
  }) async {
    if (_isLocalDashboardId(dashboardId)) {
      return _getFallbackDashboardTabs(dashboardId: dashboardId);
    }

    try {
      final tabsDto = await apiService.getDashboardTabs(
        dashboardId: dashboardId,
      );

      final remoteTabs = DashboardMapper.tabsToDomain(tabsDto);

      if (remoteTabs.isEmpty) {
        return _getFallbackDashboardTabs(dashboardId: dashboardId);
      }

      await localDataSource.cacheTabs(
        dashboardId: dashboardId,
        tabs: remoteTabs,
      );

      return remoteTabs;
    } catch (_) {
      return _getFallbackDashboardTabs(dashboardId: dashboardId);
    }
  }

  @override
  Future<DashboardTab> createDashboardTab({
    required String dashboardId,
    required String name,
  }) async {
    final normalizedName = _normalizeTabName(name);

    if (_isLocalDashboardId(dashboardId)) {
      throw StateError(
        'No se puede crear un dashboard remoto sin dashboard raíz remoto',
      );
    }

    final currentTabsDto = await apiService.getDashboardTabs(
      dashboardId: dashboardId,
    );

    final nextTabIndex = _nextRemoteTabIndex(currentTabsDto.tabs);

    final createdTabDto = await apiService.createDashboardTab(
      dashboardId: dashboardId,
      name: normalizedName,
      tabIndex: nextTabIndex,
    );

    final createdTab = DashboardMapper.tabToDomain(createdTabDto);

    if (createdTab.id.trim().isEmpty) {
      throw StateError('La tab creada no tiene id válido');
    }

    try {
      final refreshedTabsDto = await apiService.getDashboardTabs(
        dashboardId: dashboardId,
      );

      final refreshedTabs = DashboardMapper.tabsToDomain(refreshedTabsDto);

      if (refreshedTabs.isNotEmpty) {
        await localDataSource.cacheTabs(
          dashboardId: dashboardId,
          tabs: refreshedTabs,
        );

        return refreshedTabs.firstWhere(
          (tab) => tab.id == createdTab.id,
          orElse: () => createdTab,
        );
      }
    } catch (_) {}

    await _cacheCreatedRemoteTab(
      dashboardId: dashboardId,
      createdTab: createdTab,
    );

    return createdTab;
  }

  @override
  Future<DashboardTab> renameDashboardTab({
    required String dashboardId,
    required String tabId,
    required String name,
  }) async {
    final normalizedName = _normalizeTabName(name);

    if (_isLocalDashboardId(dashboardId)) {
      return localDataSource.renameLocalTab(
        dashboardId: dashboardId,
        tabId: tabId,
        name: normalizedName,
      );
    }

    final currentTabsDto = await apiService.getDashboardTabs(
      dashboardId: dashboardId,
    );

    final currentTabDto = currentTabsDto.tabs.firstWhere(
      (tab) => tab.id == tabId,
      orElse: () => throw StateError('No se encontró la tab remota'),
    );

    final remoteTabIndex = currentTabDto.index;

    if (remoteTabIndex == null) {
      throw StateError('La tab remota no tiene tab_index válido');
    }

    final updatedTabDto = await apiService.renameDashboardTab(
      dashboardId: dashboardId,
      tabId: tabId,
      name: normalizedName,
      tabIndex: remoteTabIndex,
    );

    final updatedTab = DashboardMapper.tabToDomain(updatedTabDto);

    try {
      final refreshedTabsDto = await apiService.getDashboardTabs(
        dashboardId: dashboardId,
      );

      final refreshedTabs = DashboardMapper.tabsToDomain(refreshedTabsDto);

      if (refreshedTabs.isNotEmpty) {
        await localDataSource.cacheTabs(
          dashboardId: dashboardId,
          tabs: refreshedTabs,
        );

        return refreshedTabs.firstWhere(
          (tab) => tab.id == updatedTab.id,
          orElse: () => updatedTab,
        );
      }
    } catch (_) {}

    await _cacheCreatedRemoteTab(
      dashboardId: dashboardId,
      createdTab: updatedTab,
    );

    return updatedTab;
  }

  @override
  Future<List<DashboardTab>> updateDashboardTabOrder({
    required String dashboardId,
    required List<DashboardTab> tabs,
  }) async {
    if (tabs.isEmpty) {
      throw StateError('Debe existir al menos un dashboard');
    }

    return localDataSource.updateLocalTabOrder(
      dashboardId: dashboardId,
      tabs: tabs,
    );
  }

  @override
  Future<void> deleteDashboardTab({
    required String dashboardId,
    required String tabId,
  }) async {
    if (_isLocalDashboardId(dashboardId)) {
      await localDataSource.deleteLocalTab(
        dashboardId: dashboardId,
        tabId: tabId,
      );
      return;
    }

    await apiService.deleteDashboardTab(
      dashboardId: dashboardId,
      tabId: tabId,
    );

    await _removeTabFromLocalCache(
      dashboardId: dashboardId,
      tabId: tabId,
    );
  }

  @override
  Future<List<DashboardWidgetItem>> getTabItems({
    required String dashboardId,
    required String tabId,
  }) async {
    if (_isLocalDashboardId(dashboardId) ||
        _isLocalTabId(dashboardId: dashboardId, tabId: tabId)) {
      return _getFallbackTabItems(dashboardId: dashboardId, tabId: tabId);
    }

    try {
      final responseDto = await apiService.getTabWidgets(
        dashboardId: dashboardId,
        tabId: tabId,
        userId: _currentUserId,
      );

      final remoteWidgets = DashboardWidgetMapper.toDomainList(responseDto);

      if (remoteWidgets.isEmpty) {
        return _getFallbackTabItems(dashboardId: dashboardId, tabId: tabId);
      }

      await localDataSource.cacheTabWidgets(
        tabId: tabId,
        widgets: remoteWidgets,
      );

      return remoteWidgets;
    } catch (_) {
      return _getFallbackTabItems(tabId: tabId, dashboardId: dashboardId);
    }
  }

  @override
  Future<List<WidgetCatalogItem>> getWidgetCatalog() async {
    try {
      final catalogDtos = await apiService.getWidgetCatalog();
      final remoteCatalog = WidgetCatalogMapper.toDomainList(catalogDtos);

      if (remoteCatalog.isNotEmpty) {
        return remoteCatalog;
      }

      return FallbackWidgetCatalog.items;
    } catch (_) {
      return FallbackWidgetCatalog.items;
    }
  }

  @override
  Future<List<DashboardWidgetItem>> addTabWidget({
    required String tabId,
    required WidgetCatalogItem catalogItem,
  }) async {
    final cachedWidgets = await localDataSource.getCachedTabWidgets(
      tabId: tabId,
    );

    final widgetId = '${tabId}_${catalogItem.id}';

    final alreadyExists = cachedWidgets.any((widget) => widget.id == widgetId);

    if (alreadyExists) {
      throw StateError('El widget ya existe en este dashboard');
    }

    final newWidget = DashboardWidgetItem(
      id: widgetId,
      title: catalogItem.title,
      type: catalogItem.type,
      status: WidgetStatus.inactive,
      primaryValue: 'Sin datos',
      description: catalogItem.description,
      position: cachedWidgets.length,
    );

    final updatedWidgets = [...cachedWidgets, newWidget];

    final normalizedWidgets = [
      for (var i = 0; i < updatedWidgets.length; i++)
        updatedWidgets[i].copyWith(position: i),
    ];

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: normalizedWidgets,
    );

    return normalizedWidgets;
  }

  @override
  Future<List<DashboardWidgetItem>> deleteTabWidget({
    required String tabId,
    required String widgetId,
  }) async {
    final cachedWidgets = await localDataSource.getCachedTabWidgets(
      tabId: tabId,
    );

    final updatedWidgets = cachedWidgets
        .where((widget) => widget.id != widgetId)
        .toList();

    if (updatedWidgets.length == cachedWidgets.length) {
      throw StateError('El widget no existe en este dashboard');
    }

    final normalizedWidgets = [
      for (var i = 0; i < updatedWidgets.length; i++)
        updatedWidgets[i].copyWith(position: i),
    ];

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: normalizedWidgets,
    );

    return normalizedWidgets;
  }

  @override
  Future<List<DashboardWidgetItem>> updateTabWidgetOrder({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  }) async {
    final normalizedWidgets = <DashboardWidgetItem>[];

    for (var i = 0; i < widgets.length; i++) {
      normalizedWidgets.add(widgets[i].copyWith(position: i));
    }

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: normalizedWidgets,
    );

    return normalizedWidgets;
  }

  Future<void> _removeTabFromLocalCache({
    required String dashboardId,
    required String tabId,
  }) async {
    final cachedTabs = await localDataSource.getCachedTabs(
      dashboardId: dashboardId,
    );

    if (cachedTabs.length <= 1) {
      await localDataSource.deleteLocalTab(
        dashboardId: dashboardId,
        tabId: tabId,
      );
      return;
    }

    final updatedTabs = cachedTabs.where((tab) => tab.id != tabId).toList();

    if (updatedTabs.length == cachedTabs.length) {
      return;
    }

    final normalizedTabs = [
      for (var i = 0; i < updatedTabs.length; i++)
        updatedTabs[i].copyWith(position: i),
    ];

    await localDataSource.cacheTabs(
      dashboardId: dashboardId,
      tabs: normalizedTabs,
    );

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: const [],
    );
  }

  Future<Dashboard> _getFallbackDashboard(String userId) async {
    final dashboardId = _dashboardIdForUser(userId);

    final cachedDashboard = await localDataSource.getCachedDashboard(
      dashboardId: dashboardId,
    );

    if (cachedDashboard != null) {
      return cachedDashboard;
    }

    final dashboard = Dashboard(id: dashboardId, theme: null, language: null);

    await localDataSource.cacheDashboard(dashboard);

    return dashboard;
  }

  Future<List<DashboardTab>> _getFallbackDashboardTabs({
    required String dashboardId,
  }) async {
    final cachedTabs = await localDataSource.getCachedTabs(
      dashboardId: dashboardId,
    );

    if (cachedTabs.isNotEmpty) {
      return cachedTabs;
    }

    final initialTabs = [
      DashboardTab(
        id: _defaultTabIdForDashboard(dashboardId),
        position: 0,
        name: 'Widgets',
      ),
    ];

    await localDataSource.cacheTabs(
      dashboardId: dashboardId,
      tabs: initialTabs,
    );

    return initialTabs;
  }

  Future<void> _cacheCreatedRemoteTab({
    required String dashboardId,
    required DashboardTab createdTab,
  }) async {
    final cachedTabs = await localDataSource.getCachedTabs(
      dashboardId: dashboardId,
    );

    final mergedTabs = [
      ...cachedTabs.where((tab) => tab.id != createdTab.id),
      createdTab,
    ]..sort((a, b) => a.position.compareTo(b.position));

    final normalizedTabs = [
      for (var i = 0; i < mergedTabs.length; i++)
        mergedTabs[i].copyWith(position: i),
    ];

    await localDataSource.cacheTabs(
      dashboardId: dashboardId,
      tabs: normalizedTabs,
    );
  }

  Future<List<DashboardWidgetItem>> _getFallbackTabItems({
    required String dashboardId,
    required String tabId,
  }) async {
    final cachedWidgets = await localDataSource.getCachedTabWidgets(
      tabId: tabId,
    );

    if (cachedWidgets.isNotEmpty) {
      return cachedWidgets;
    }

    return [];
  }

  String get _currentUserId {
    final userId = sessionStorageService.userId;

    if (userId == null || userId.isEmpty) {
      throw Exception('No hay usuario autenticado');
    }

    return userId;
  }

  String _dashboardIdForUser(String userId) {
    return 'dashboard_$userId';
  }

  String _defaultTabIdForDashboard(String dashboardId) {
    return '${dashboardId}_widgets';
  }

  String _normalizeTabName(String name) {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw StateError('Introduce un nombre');
    }

    return normalizedName;
  }

  bool _isLocalDashboardId(String dashboardId) {
    return dashboardId.startsWith('dashboard_');
  }

  bool _isLocalTabId({required String dashboardId, required String tabId}) {
    return tabId == _defaultTabIdForDashboard(dashboardId) ||
        tabId.startsWith('${dashboardId}_local_');
  }

  int _nextRemoteTabIndex(List<DashboardTabDto> tabs) {
    if (tabs.isEmpty) {
      return 1;
    }

    var maxIndex = 0;

    for (final tab in tabs) {
      final tabIndex = tab.index;

      if (tabIndex != null && tabIndex > maxIndex) {
        maxIndex = tabIndex;
      }
    }

    return maxIndex + 1;
  }
}
