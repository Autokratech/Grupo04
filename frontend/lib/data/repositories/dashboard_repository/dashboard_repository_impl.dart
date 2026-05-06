import 'package:frontend/data/mappers/dashboard_mapper.dart';
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

    final createdTabDto = await apiService.createDashboardTab(
      dashboardId: dashboardId,
      name: normalizedName,
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
    } catch (_) {
    }

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
    return localDataSource.renameLocalTab(
      dashboardId: dashboardId,
      tabId: tabId,
      name: _normalizeTabName(name),
    );
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
    if (_isLocalDashboardId(dashboardId) ||
        _isLocalTabId(dashboardId: dashboardId, tabId: tabId)) {
      return _getFallbackTabItems(dashboardId: dashboardId, tabId: tabId);
    }

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

    if (tabId != _defaultTabIdForDashboard(dashboardId)) {
      return [];
    }

    final initialWidgets = _buildInitialWidgetItems(tabId)
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

  bool _isLocalTabId({
    required String dashboardId,
    required String tabId,
  }) {
    return tabId == _defaultTabIdForDashboard(dashboardId) ||
        tabId.startsWith('${dashboardId}_local_');
  }

  // TODO: sustituir por widgets recibidos desde backend.
  List<DashboardWidgetItem> _buildInitialWidgetItems(String tabId) {
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
        description: 'Estado actual del proceso de sincronización entre sistemas.',
        position: 2,
      ),
      DashboardWidgetItem(
        id: '${tabId}_cpu-usage',
        title: 'Uso de CPU',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '42%',
        description: 'Carga media actual del procesador del agente principal.',
        position: 3,
      ),
      DashboardWidgetItem(
        id: '${tabId}_memory-usage',
        title: 'Uso de memoria',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '68%',
        description: 'Porcentaje de memoria utilizada en el entorno monitorizado.',
        position: 4,
      ),
      DashboardWidgetItem(
        id: '${tabId}_disk-space',
        title: 'Espacio en disco',
        type: WidgetType.metric,
        status: WidgetStatus.error,
        primaryValue: '91%',
        description: 'Uso actual del almacenamiento principal.',
        position: 5,
      ),
      DashboardWidgetItem(
        id: '${tabId}_deployments',
        title: 'Despliegues recientes',
        type: WidgetType.list,
        status: WidgetStatus.ok,
        primaryValue: '5',
        description: 'Despliegues registrados durante las últimas 24 horas.',
        position: 6,
      ),
      DashboardWidgetItem(
        id: '${tabId}_failed-jobs',
        title: 'Jobs fallidos',
        type: WidgetType.alert,
        status: WidgetStatus.error,
        primaryValue: '2',
        description: 'Tareas automatizadas que han terminado con error.',
        position: 7,
      ),
      DashboardWidgetItem(
        id: '${tabId}_api-latency',
        title: 'Latencia API',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '128 ms',
        description: 'Tiempo medio de respuesta de la API principal.',
        position: 8,
      ),
      DashboardWidgetItem(
        id: '${tabId}_cloud-cost',
        title: 'Coste cloud',
        type: WidgetType.chart,
        status: WidgetStatus.ok,
        primaryValue: '248 €',
        description: 'Estimación provisional del coste mensual acumulado.',
        position: 9,
      ),
      DashboardWidgetItem(
        id: '${tabId}_security-alerts',
        title: 'Alertas de seguridad',
        type: WidgetType.alert,
        status: WidgetStatus.inactive,
        primaryValue: 'Sin datos',
        description: 'Estado pendiente de integración con proveedor de seguridad.',
        position: 10,
      ),
      DashboardWidgetItem(
        id: '${tabId}_repository-status',
        title: 'Repositorios',
        type: WidgetType.service,
        status: WidgetStatus.ok,
        primaryValue: '8',
        description: 'Repositorios vinculados pendientes de integración real.',
        position: 11,
      ),
      DashboardWidgetItem(
        id: '${tabId}_pipeline-status',
        title: 'Pipelines',
        type: WidgetType.list,
        status: WidgetStatus.error,
        primaryValue: '1 fallido',
        description: 'Resumen provisional del estado de pipelines recientes.',
        position: 12,
      ),
      DashboardWidgetItem(
        id: '${tabId}_agent-health',
        title: 'Estado agentes',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Todos online',
        description: 'Estado general de los agentes instalados.',
        position: 13,
      ),
    ];
  }
}
