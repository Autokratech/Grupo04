import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/domain/models/widget_type.dart';

class WidgetCatalogMock {
  const WidgetCatalogMock._();

  static const List<WidgetCatalogItem> items = [
    WidgetCatalogItem(
      id: 'active-services',
      title: 'Servicios activos',
      type: WidgetType.service,
      description: 'Muestra cuántos servicios monitorizados están operativos.',
      requirementLabel: 'Requiere agente',
    ),
    WidgetCatalogItem(
      id: 'open-incidents',
      title: 'Incidencias abiertas',
      type: WidgetType.alert,
      description: 'Muestra incidencias pendientes de revisión o resolución.',
      requirementLabel: 'Requiere proveedor o agente',
    ),
    WidgetCatalogItem(
      id: 'sync-status',
      title: 'Sincronización',
      type: WidgetType.status,
      description: 'Indica el estado general de sincronización entre integraciones.',
      requirementLabel: 'Requiere integraciones activas',
    ),
    WidgetCatalogItem(
      id: 'cpu-usage',
      title: 'Uso de CPU',
      type: WidgetType.metric,
      description: 'Muestra la carga de procesador enviada por un agente.',
      requirementLabel: 'Requiere agente',
    ),
    WidgetCatalogItem(
      id: 'memory-usage',
      title: 'Uso de memoria',
      type: WidgetType.metric,
      description: 'Muestra el porcentaje de memoria utilizada.',
      requirementLabel: 'Requiere agente',
    ),
    WidgetCatalogItem(
      id: 'disk-space',
      title: 'Espacio en disco',
      type: WidgetType.metric,
      description: 'Muestra el uso del almacenamiento principal.',
      requirementLabel: 'Requiere agente',
    ),
    WidgetCatalogItem(
      id: 'deployments',
      title: 'Despliegues recientes',
      type: WidgetType.list,
      description: 'Lista despliegues recientes desde proveedores CI/CD.',
      requirementLabel: 'Requiere GitHub o GitLab',
    ),
    WidgetCatalogItem(
      id: 'failed-jobs',
      title: 'Jobs fallidos',
      type: WidgetType.alert,
      description: 'Muestra tareas automatizadas terminadas con error.',
      requirementLabel: 'Requiere proveedor CI/CD',
    ),
    WidgetCatalogItem(
      id: 'api-latency',
      title: 'Latencia API',
      type: WidgetType.metric,
      description: 'Muestra el tiempo medio de respuesta de la API principal.',
      requirementLabel: 'Requiere agente o backend monitorizado',
    ),
    WidgetCatalogItem(
      id: 'cloud-cost',
      title: 'Coste cloud',
      type: WidgetType.chart,
      description: 'Muestra una estimación del coste cloud acumulado.',
      requirementLabel: 'Requiere proveedor cloud',
    ),
    WidgetCatalogItem(
      id: 'security-alerts',
      title: 'Alertas de seguridad',
      type: WidgetType.alert,
      description: 'Muestra alertas relacionadas con seguridad o configuración.',
      requirementLabel: 'Requiere proveedor de seguridad',
    ),
    WidgetCatalogItem(
      id: 'repository-status',
      title: 'Repositorios',
      type: WidgetType.service,
      description: 'Muestra repositorios vinculados y su estado general.',
      requirementLabel: 'Requiere GitHub o GitLab',
    ),
    WidgetCatalogItem(
      id: 'pipeline-status',
      title: 'Pipelines',
      type: WidgetType.pipeline,
      description: 'Muestra el estado de pipelines recientes.',
      requirementLabel: 'Requiere GitHub o GitLab',
    ),
    WidgetCatalogItem(
      id: 'agent-health',
      title: 'Estado agentes',
      type: WidgetType.status,
      description: 'Muestra el estado general de los agentes registrados.',
      requirementLabel: 'Requiere agente',
    ),
    WidgetCatalogItem(
      id: 'merge-requests',
      title: 'Merge requests',
      type: WidgetType.issue,
      description: 'Muestra merge requests abiertas o pendientes de revisión.',
      requirementLabel: 'Requiere GitLab',
    ),
    WidgetCatalogItem(
      id: 'gauge',
      title: 'Gauge',
      type: WidgetType.metric,
      description: 'Muestra una métrica puntual en formato indicador.',
      requirementLabel: 'Requiere datos métricos',
    ),
  ];
}