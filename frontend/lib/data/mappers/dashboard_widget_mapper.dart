import 'package:frontend/data/models/dto/dashboard_dtos/tab_widget_data_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tab_widget_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tab_widgets_response_dto.dart';
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
      primaryValue: _resolvePrimaryValue(widget, data),
      description: _resolveDescription(widget, data),
      position: widget.widgetIndex ?? 0,
    );
  }

  static WidgetType _mapWidgetType(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'metric':
      case 'gauge':
      case 'progress_bar':
      case 'cost_management':
        return WidgetType.metric;

      case 'list':
      case 'text_list':
      case 'pipeline_list':
      case 'list_resources':
        return WidgetType.list;

      case 'chart':
      case 'bar_chart':
      case 'pie_chart':
      case 'line_chart':
      case 'area_chart':
        return WidgetType.chart;

      case 'service':
        return WidgetType.service;

      case 'alert':
        return WidgetType.alert;

      case 'pipeline':
        return WidgetType.pipeline;

      case 'issue':
      case 'merge_request':
        return WidgetType.issue;

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
          _formatFallbackLabel(widget.widgetTitle),
          _formatFallbackLabel(widget.widgetType),
          _formatFallbackLabel(data?.providerTag),
        ]) ??
        'Widget';
  }

  static String _resolvePrimaryValue(
    TabWidgetDto widget,
    TabWidgetDataDto? data,
  ) {
    final payload = data?.data ?? {};

    final explicitPrimaryValue = _firstNonEmpty([
      _stringOrNull(payload['primary_value']),
      _stringOrNull(payload['primaryValue']),
    ]);

    if (explicitPrimaryValue != null) {
      return explicitPrimaryValue;
    }

    if (_isCostManagementWidget(widget)) {
      final costValue = _resolveCostValue(payload);

      if (costValue != null) {
        return costValue;
      }
    }

    final value = payload['value'];
    final unit = _stringOrNull(payload['unit']);

    if (value != null) {
      return unit == null ? value.toString() : '${value.toString()}$unit';
    }

    final count = _parseNumber(payload['count']);
    if (count != null) {
      final normalizedCount = count.toInt();

      if (_isResourceListWidget(widget)) {
        return _formatResourceCount(widget, normalizedCount);
      }

      return normalizedCount.toString();
    }

    final total = payload['total'];
    if (total != null) {
      return total.toString();
    }

    final items = payload['items'];
    if (items is List) {
      if (_isResourceListWidget(widget)) {
        return _formatResourceCount(widget, items.length);
      }

      return '${items.length} elementos';
    }

    return 'Sin datos';
  }

  static String? _resolveDescription(
    TabWidgetDto widget,
    TabWidgetDataDto? data,
  ) {
    final explicitDescription = _firstNonEmpty([
      _stringOrNull(data?.data['description']),
      _stringOrNull(data?.data['message']),
      _stringOrNull(data?.data['summary']),
    ]);

    if (explicitDescription != null) {
      return explicitDescription;
    }

    final provider = _formatFallbackLabel(data?.providerTag);
    final dataType = _formatFallbackLabel(widget.dataType);

    if (provider != null && dataType != null) {
      return '$dataType desde $provider.';
    }

    if (provider != null) {
      return 'Datos recibidos desde $provider.';
    }

    return null;
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
        .map((part) {
          final lowerPart = part.toLowerCase();
          return '${lowerPart[0].toUpperCase()}${lowerPart.substring(1)}';
        })
        .join(' ');
  }

  static bool _isResourceListWidget(TabWidgetDto widget) {
    return widget.widgetType?.toLowerCase().trim() == 'list_resources';
  }

  static bool _isCostManagementWidget(TabWidgetDto widget) {
    final widgetType = widget.widgetType?.toLowerCase().trim();
    final dataType = widget.dataType?.toLowerCase().trim();

    return widgetType == 'cost_management' || dataType == 'cost_management';
  }

  static String? _resolveCostValue(Map<String, dynamic> payload) {
    final directCost = _parseNumber(payload['total_cost']);
    final directCurrency = _stringOrNull(payload['currency']);

    if (directCost != null) {
      return _formatCurrencyValue(directCost, directCurrency);
    }

    final firstItem = _firstMapFromItems(payload['items']);
    final itemCost = _parseNumber(firstItem?['total_cost']);
    final itemCurrency = _stringOrNull(firstItem?['currency']);

    if (itemCost != null) {
      return _formatCurrencyValue(itemCost, itemCurrency);
    }

    return null;
  }

  static Map<String, dynamic>? _firstMapFromItems(dynamic items) {
    if (items is! List || items.isEmpty) {
      return null;
    }

    for (final item in items) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
    }

    return null;
  }

  static num? _parseNumber(dynamic value) {
    if (value is num) {
      return value;
    }

    if (value is String) {
      return num.tryParse(value);
    }

    return null;
  }

  static String _formatCurrencyValue(num value, String? currency) {
    final formattedValue = value.toDouble().toStringAsFixed(2);

    if (currency == null || currency.isEmpty) {
      return formattedValue;
    }

    return '$formattedValue $currency';
  }

  static String _formatResourceCount(TabWidgetDto widget, int count) {
    final dataType = widget.dataType?.toLowerCase().trim();

    switch (dataType) {
      case 'resource_groups':
        return count == 1 ? '1 grupo' : '$count grupos';

      case 'virtual_machines':
        return count == 1 ? '1 VM' : '$count VMs';

      case 'key_vaults':
        return count == 1 ? '1 Key Vault' : '$count Key Vaults';

      default:
        return count == 1 ? '1 recurso' : '$count recursos';
    }
  }
}
