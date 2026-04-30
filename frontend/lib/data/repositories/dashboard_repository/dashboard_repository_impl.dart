import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({required this.localDataSource});

  final Dashboard _dashboard = const Dashboard(
    id: 'local-dashboard',
    theme: null,
    language: null,
  );

  final List<DashboardTab> _tabs = [
    DashboardTab(id: 'widgets', position: 0, name: 'Widgets'),
  ];

  @override
  Future<Dashboard> getDashboard() async {
    final cachedDashboard = await localDataSource.getCachedDashboard();

    if (cachedDashboard != null) {
      return cachedDashboard;
    }

    await localDataSource.cacheDashboard(_dashboard);

    return _dashboard;
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

    final initialTabs = [..._tabs]
      ..sort((a, b) => a.position.compareTo(b.position));

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
  Future<List<DashboardWidgetItem>> getTabItems({required String tabId}) async {
    final cachedWidgets = await localDataSource.getCachedTabWidgets(
      tabId: tabId,
    );

    if (cachedWidgets.isNotEmpty) {
      return cachedWidgets;
    }

    if (tabId != 'widgets') return [];

    final initialWidgets = _buildWidgetsItems()
      ..sort((a, b) => a.position.compareTo(b.position));

    await localDataSource.cacheTabWidgets(
      tabId: tabId,
      widgets: initialWidgets,
    );

    return initialWidgets;
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

    await localDataSource.cacheTabWidgets(tabId: tabId, widgets: widgets);

    return normalizedWidgets;
  }

  // TODO: sustituir por widgets recibidos desde backend.
  List<DashboardWidgetItem> _buildWidgetsItems() {
    return [
      DashboardWidgetItem(
        id: 'active-services',
        title: 'Servicios activos',
        type: WidgetType.service,
        status: WidgetStatus.ok,
        primaryValue: '12',
        description: 'Número total de servicios operativos en este momento.',
        position: 0,
      ),
      DashboardWidgetItem(
        id: 'open-incidents',
        title: 'Incidencias abiertas',
        type: WidgetType.alert,
        status: WidgetStatus.error,
        primaryValue: '3',
        description: 'Incidencias actualmente pendientes de revisión o cierre.',
        position: 1,
      ),
      DashboardWidgetItem(
        id: 'sync-status',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
            'Estado actual del proceso de sincronización entre sistemas.',
        position: 2,
      ),
    ];
  }
}
