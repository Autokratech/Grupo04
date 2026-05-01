import 'package:frontend/data/models/dto/tab_widget_data_dto.dart';
import 'package:frontend/data/models/dto/tab_widget_dto.dart';
import 'package:frontend/data/models/dto/tab_widgets_response_dto.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardWidgetMapper {
  const DashboardWidgetMapper._();

  static List<DashboardWidgetItem> toDomainList(TabWidgetsResponseDto dto) {
    final dataByWidgetId = <String, TabWidgetDataDto>{
      for (final data in dto.tabWidgetsData)
        if (data.tabWidgetId.isNotEmpty) data.tabWidgetId: data,
    };

    final items = dto.tabWidgets
        .where((widget) => widget.tabWidgetId.isNotEmpty)
        .map((widget) => _toDomain(widget, dataByWidgetId[widget.tabWidgetId]))
        .toList();

    items.sort((a, b) => a.position.compareTo(b.position));

    return List.generate(
      items.length,
      (index) => items[index].copyWith(position: index),
    );
  }

  static DashboardWidgetItem _toDomain(
    TabWidgetDto widget,
    TabWidgetDataDto? data,
  ) {
    return DashboardWidgetItem(
      id: widget.tabWidgetId,
      title: _resolveTitle(widget, data),
      type: _mapWidgetType(widget.widgetType),
      status: _mapWidgetStatus(data?.status),
      primaryValue: _resolvePrimaryValue(data),
      description: _resolveDescription(data),
      position: widget.widgetIndex ?? 0,
    );
  }

  static WidgetType _mapWidgetType(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'metric':
        return WidgetType.metric;
      case 'list':
      case 'pipeline_list':
        return WidgetType.list;
      case 'chart':
      case 'bar_chart':
      case 'pie_chart':
        return WidgetType.chart;
      case 'service':
        return WidgetType.service;
      case 'alert':
        return WidgetType.alert;
      case 'status':
        return WidgetType.status;
      default:
        return WidgetType.status;
    }
  }

  static WidgetStatus _mapWidgetStatus(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'ok':
      case 'success':
      case 'active':
        return WidgetStatus.ok;
      case 'error':
      case 'failed':
      case 'failure':
        return WidgetStatus.error;
      case 'inactive':
      case 'disabled':
      case 'unknown':
      default:
        return WidgetStatus.inactive;
    }
  }

  static String _resolveTitle(TabWidgetDto widget, TabWidgetDataDto? data) {
    return _firstNonEmpty([
          _stringOrNull(widget.customConfig['title']),
          _stringOrNull(widget.customConfig['name']),
          _stringOrNull(widget.customConfig['label']),
          _stringOrNull(data?.data['title']),
          _stringOrNull(data?.data['name']),
          _stringOrNull(data?.data['label']),
          _formatFallbackLabel(widget.dataType),
          _formatFallbackLabel(widget.widgetType),
          _stringOrNull(data?.providerTag),
        ]) ??
        'Widget';
  }

  static String _resolvePrimaryValue(TabWidgetDataDto? data) {
    final payload = data?.data ?? {};

    final explicitPrimaryValue = _firstNonEmpty([
      _stringOrNull(payload['primary_value']),
      _stringOrNull(payload['primaryValue']),
    ]);

    if (explicitPrimaryValue != null) {
      return explicitPrimaryValue;
    }

    final value = payload['value'];
    final unit = _stringOrNull(payload['unit']);

    if (value != null) {
      return unit == null ? value.toString() : '${value.toString()}$unit';
    }

    final count = payload['count'];
    if (count != null) {
      return count.toString();
    }

    final total = payload['total'];
    if (total != null) {
      return total.toString();
    }

    final items = payload['items'];
    if (items is List) {
      return '${items.length} elementos';
    }

    return 'Sin datos';
  }

  static String? _resolveDescription(TabWidgetDataDto? data) {
    return _firstNonEmpty([
      _stringOrNull(data?.data['description']),
      _stringOrNull(data?.data['message']),
      _stringOrNull(data?.data['summary']),
      _stringOrNull(data?.providerTag),
    ]);
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  static String? _formatFallbackLabel(String? value) {
    final text = _stringOrNull(value);

    if (text == null) {
      return null;
    }

    return text
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
