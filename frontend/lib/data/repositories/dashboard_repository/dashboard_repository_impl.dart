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
    DashboardTab(id: 'catalog', position: 1, name: 'Catálogo'),
    DashboardTab(id: 'operations', position: 2, name: 'Operaciones'),
    DashboardTab(id: 'pc_resources', position: 3, name: 'Recursos PC'),
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
      case 'catalog':
        return _buildCatalogItems();
      case 'operations':
        return _buildOperationsItems();
      case 'pc_resources':
        return _buildPcResourcesItems();
      default:
        return [];
    }
  }

  // TODO: acabará eliminado
  List<DashboardWidgetItem> _buildCatalogItems() {
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

  // TODO: acabará eliminado
  List<DashboardWidgetItem> _buildOperationsItems() {
    return [
      DashboardWidgetItem(
        id: 'pending-forms',
        title: 'Formularios pendientes',
        type: WidgetType.alert,
        status: WidgetStatus.error,
        primaryValue: '8',
        description:
            'Formularios aún no procesados por el equipo de operaciones.',
      ),
      DashboardWidgetItem(
        id: 'failed-services',
        title: 'Servicios con error',
        type: WidgetType.service,
        status: WidgetStatus.error,
        primaryValue: '2',
        description:
            'Servicios que han registrado fallos y requieren intervención.',
      ),
      DashboardWidgetItem(
        id: 'avg-response-time',
        title: 'Tiempo medio de respuesta',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '240 ms',
      ),
    ];
  }

  // TODO: acabará eliminado
  List<DashboardWidgetItem> _buildPcResourcesItems() {
    return [
      DashboardWidgetItem(
        id: 'cpu-usage',
        title: 'Uso de CPU',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '34%',
        description:
            'Porcentaje actual de uso del procesador del equipo monitorizado.',
      ),
      DashboardWidgetItem(
        id: 'ram-usage',
        title: 'Uso de RAM',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '68%',
        description: 'Memoria RAM utilizada actualmente por el sistema.',
      ),
      DashboardWidgetItem(
        id: 'disk-space',
        title: 'Espacio en disco',
        type: WidgetType.metric,
        status: WidgetStatus.ok,
        primaryValue: '120 GB',
        description:
            'Espacio disponible actualmente en el almacenamiento principal.',
      ),
      DashboardWidgetItem(
        id: 'network-status',
        title: 'Red',
        type: WidgetType.status,
        status: WidgetStatus.ok,
        primaryValue: 'Conectada',
      ),
    ];
  }
}
