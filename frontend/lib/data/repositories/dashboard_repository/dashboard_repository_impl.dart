import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardRepositoryImpl implements DashboardRepository {
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
    return [];
  }

  List<DashboardWidgetItem> _buildPcResourcesItems() {
    return [];
  }
}
