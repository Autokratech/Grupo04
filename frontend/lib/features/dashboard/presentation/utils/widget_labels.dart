import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class WidgetLabels {
  const WidgetLabels._();

  static String status(WidgetStatus status) {
    switch (status) {
      case WidgetStatus.ok:
        return 'OK';
      case WidgetStatus.error:
        return 'Error';
      case WidgetStatus.inactive:
        return 'Sin datos';
    }
  }

  static String type(WidgetType type) {
    switch (type) {
      case WidgetType.status:
        return 'Estado';
      case WidgetType.metric:
        return 'Métrica';
      case WidgetType.list:
        return 'Lista';
      case WidgetType.chart:
        return 'Gráfico';
      case WidgetType.service:
        return 'Servicio';
      case WidgetType.alert:
        return 'Alerta';
      case WidgetType.pipeline:
        return 'Pipeline';
      case WidgetType.issue:
        return 'Issue';
    }
  }

  static String provider(String? provider) {
    final normalizedProvider = provider?.trim().toLowerCase();

    if (normalizedProvider == null || normalizedProvider.isEmpty) {
      return 'Unknown';
    }

    switch (normalizedProvider) {
      case 'github':
        return 'GitHub';
      case 'gitlab':
        return 'GitLab';
      case 'azure':
        return 'Azure';
      case 'gcp':
        return 'Google Cloud';
      case 'windows':
        return 'Windows';
      case 'linux':
        return 'Linux';
      case 'agent':
        return 'Agente local';
      default:
        return '$provider';
    }
  }
}
