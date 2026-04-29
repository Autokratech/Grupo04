import 'package:frontend/core/constants/app_constants.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/domain/models/dashboard.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final Dashboard _dashboard = const Dashboard(
    id: 'local-dashboard',
    theme: null,
    language: null,
  );

  final List<DashboardTab> _tabs = [
    DashboardTab(id: 'widgets', position: 1, name: 'Widgets'),
  ];

  @override
  Future<Dashboard> getDashboard() async {
    return _dashboard;
  }

  @override
  Future<List<DashboardTab>> getDashboardTabs({
    required String dashboardId,
  }) async {
    final tabs = [..._tabs]..sort((a, b) => a.position.compareTo(b.position));
    return tabs;
  }

  @override
  Future<DashboardTab> createDashboardTab({
    required String dashboardId,
    required String name,
  }) async {
    if (_tabs.length >= AppConstants.maxTabs) {
      throw Exception('No se pueden crear más de ${AppConstants.maxTabs} pestañas');
    }

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw Exception('El nombre de la pestaña no puede estar vacío');
    }

    final newTab = DashboardTab(
      id: 'local-tab-${DateTime.now().microsecondsSinceEpoch}',
      position: _tabs.length,
      name: normalizedName,
    );

    _tabs.add(newTab);

    return newTab;
  }

  @override
  Future<List<DashboardWidgetItem>> getTabItems({
    required String tabId,
  }) async {
    switch (tabId) {
      case 'widgets':
        return _buildWidgetsItems();
      default:
        return [];
    }
  }

  // TODO: acabará eliminado
  List<DashboardWidgetItem> _buildWidgetsItems() {
    return [
      DashboardWidgetItem(
        id: 'active-services',
        title: 'Servicios activos',
        type: WidgetType.service,
        status: WidgetStatus.ok,
        primaryValue: '12',
        description: 'Número total de servicios operativos en este momento.',
      ),
      DashboardWidgetItem(
        id: 'open-incidents',
        title: 'Incidencias abiertas',
        type: WidgetType.alert,
        status: WidgetStatus.error,
        primaryValue: '3',
        description: 'Incidencias actualmente pendientes de revisión o cierre.',
      ),
      DashboardWidgetItem(
        id: 'sync-status',
        title: 'Sincronización',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Operativa',
        description:
            'Estado actual del proceso de sincronización entre sistemas.',
      ),
    ];
  }
}
