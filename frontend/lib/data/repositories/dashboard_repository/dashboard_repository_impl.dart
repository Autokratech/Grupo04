import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<List<DashboardPreset>> getAvailablePresets() async {
    return const [
      DashboardPreset(id: 'default', name: 'Por defecto'),
      DashboardPreset(id: 'operations', name: 'Operaciones'),
      DashboardPreset(id: 'pc_resources', name: 'Recursos PC'),
    ];
  }

  @override
  Future<List<DashboardWidgetItem>> getDashboardItems({
    required String presetId,
  }) async {
    switch (presetId) {
      case 'default':
        return _buildDefaultItems();
      case 'operations':
        return _buildOperationsItems();
      case 'pc_resources':
        return _buildPcResourcesItems();
      default:
        return [];
    }
  }

  List<DashboardWidgetItem> _buildDefaultItems() {
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
