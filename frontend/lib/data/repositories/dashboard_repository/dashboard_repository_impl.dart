import 'package:frontend/data/mappers/dashboard_widget_mapper.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/data/services/local/session_storage_service.dart';
import 'package:frontend/data/services/remote/dashboard_api_service.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

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

  @override
  Future<List<DashboardTab>> getDashboardTabs({
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

  @override
  Future<DashboardTab> createDashboardTab({
    required String dashboardId,
    required String name,
  }) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw Exception('Introduce un nombre');
    }

    return localDataSource.createLocalTab(
      dashboardId: dashboardId,
      name: normalizedName,
    );
  }

  @override
  Future<void> deleteDashboardTab({
    required String dashboardId,
    required String tabId,
  }) async {
    await localDataSource.deleteLocalTab(
      dashboardId: dashboardId,
      tabId: tabId,
    );
  }

  @override
  Future<List<DashboardWidgetItem>> getTabItems({
    required String dashboardId,
    required String tabId,
  }) async {
    try {
      final responseDto = await apiService.getTabWidgets(
        dashboardId: dashboardId,
        tabId: tabId,
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
  Future<List<DashboardWidgetItem>> updateTabWidgetOrder({
    required String tabId,
    required List<DashboardWidgetItem> widgets,
  }) async {
    final normalizedWidgets = <DashboardWidgetItem>[];

    for (int i = 0; i < widgets.length; i++) {
      normalizedWidgets.add(widgets[i].copyWith(position: i));
    }

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: normalizedWidgets,
    );

    return normalizedWidgets;
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

    if (tabId != _defaultTabIdForDashboard(dashboardId)) {
      return [];
    }

    final initialWidgets = _buildWidgetsItems(tabId)
      ..sort((a, b) => a.position.compareTo(b.position));

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: initialWidgets,
    );

    return initialWidgets;
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

  // TODO: sustituir por widgets recibidos desde backend.
  List<DashboardWidgetItem> _buildWidgetsItems(String tabId) {
    return [
      DashboardWidgetItem(
        id: '${tabId}_active-services',
        title: 'Servicios activos',
        type: WidgetType.service,
        status: WidgetStatus.ok,
        primaryValue: '12',
        description: 'Número total de servicios operativos en este momento.',
        position: 0,
      ),
      DashboardWidgetItem(
        id: '${tabId}_open-incidents',
        title: 'Incidencias abiertas',
        type: WidgetType.alert,
        status: WidgetStatus.error,
        primaryValue: '3',
        description: 'Incidencias actualmente pendientes de revisión o cierre.',
        position: 1,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
            'Estado actual del proceso de sincronización entre sistemas.',
        position: 2,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status1',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 3,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status2',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 4,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status3',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 5,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status4',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 6,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status5',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 7,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status6',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 8,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status7',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 9,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status8',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 10,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status9',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 11,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status10',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 12,
      ),
      DashboardWidgetItem(
        id: '${tabId}_sync-status11',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
        'Estado actual del proceso de sincronización entre sistemas.',
        position: 13,
      ),
    ];
  }
}
