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
}