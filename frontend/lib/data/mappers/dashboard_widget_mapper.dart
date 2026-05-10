import 'package:frontend/data/models/dto/dashboard_dtos/tab_widgets/tab_widget_data_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tab_widgets/tab_widget_dto.dart';
import 'package:frontend/data/models/dto/dashboard_dtos/tab_widgets/tab_widgets_response_dto.dart';
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
    final rawData = data?.data;
    final customConfig = _resolveCustomConfig(widget);

    return DashboardWidgetItem(
      id: widget.tabWidgetId,
      title: _resolveTitle(widget, data),
      type: _mapWidgetType(widget.widgetType),
      status: _mapWidgetStatus(data?.status),
      primaryValue: _resolvePrimaryValue(widget, data),
      description: _resolveDescription(widget, data),
      position: widget.widgetIndex ?? 0,
      provider: _resolveProvider(widget, data),
      dataType: _resolveDataType(widget),
      updatedAt: data?.timestamp,
      ttl: data?.ttl,
      count: _resolveCount(rawData),
      rawData: rawData,
      customConfig: customConfig.isEmpty ? null : customConfig,
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
      case 'list_endpoints':
      case 'list_ports':
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
      case 'issue_tracking':
      case 'merge_request':
      case 'merge_request_tracker':
        return WidgetType.issue;

      case 'status':
      case 'system_data':
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

  static String? _resolveProvider(TabWidgetDto widget, TabWidgetDataDto? data) {
    final provider = _firstNonEmpty([
      _stringOrNull(data?.providerTag),
      _stringOrNull(widget.customConfig['provider']),
      _stringOrNull(widget.customConfig['provider_tag']),
      _stringOrNull(widget.customConfig['providerName']),
      _stringOrNull(widget.customConfig['provider_name']),
    ]);

    if (provider != null) {
      return provider.toLowerCase();
    }

    final dataType = widget.dataType?.toLowerCase().trim();
    final hasAgentId = _stringOrNull(widget.customConfig['agent_id']) != null;

    if (dataType == 'system_data' || hasAgentId) {
      return 'windows';
    }

    return null;
  }

  static String? _resolveDataType(TabWidgetDto widget) {
    final dataType = _stringOrNull(widget.dataType);

    if (dataType == null) {
      return null;
    }

    return dataType.toUpperCase();
  }

  static String _resolveTitle(TabWidgetDto widget, TabWidgetDataDto? data) {
    final payload = data?.data ?? const <String, dynamic>{};

    return _firstNonEmpty([
          _stringOrNull(widget.customConfig['title']),
          _stringOrNull(widget.customConfig['name']),
          _stringOrNull(widget.customConfig['label']),
          _stringOrNull(payload['title']),
          _stringOrNull(payload['name']),
          _stringOrNull(payload['label']),
          _formatFallbackLabel(widget.widgetTitle),
          _formatFallbackLabel(widget.dataType),
          _formatFallbackLabel(widget.widgetType),
          _formatFallbackLabel(data?.providerTag),
        ]) ??
        'Widget';
  }

  static String _resolvePrimaryValue(
    TabWidgetDto widget,
    TabWidgetDataDto? data,
  ) {
    final payload = data?.data ?? const <String, dynamic>{};

    if (_isErrorStatus(data?.status) && payload.isEmpty) {
      return 'Error';
    }

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

    if (_isSystemDataWidget(widget)) {
      final systemValue = _resolveSystemDataPrimaryValue(payload);

      if (systemValue != null) {
        return systemValue;
      }
    }

    final count = _parseNumber(payload['count']);
    if (count != null) {
      final normalizedCount = count.toInt();

      if (_isResourceListWidget(widget)) {
        return _formatResourceCount(widget, normalizedCount);
      }

      if (_isPortsListWidget(widget)) {
        return _formatPortCount(normalizedCount);
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

      if (_isPortsListWidget(widget)) {
        return _formatPortCount(items.length);
      }

      return '${items.length} elementos';
    }

    return 'Sin datos';
  }

  static String? _resolveDescription(
    TabWidgetDto widget,
    TabWidgetDataDto? data,
  ) {
    final payload = data?.data ?? const <String, dynamic>{};

    final explicitDescription = _firstNonEmpty([
      _stringOrNull(payload['description']),
      _stringOrNull(payload['message']),
      _stringOrNull(payload['summary']),
    ]);

    if (explicitDescription != null) {
      return explicitDescription;
    }

    final provider = _formatFallbackLabel(data?.providerTag);
    final dataType = _formatFallbackLabel(widget.dataType);

    if (_isErrorStatus(data?.status)) {
      if (provider != null && dataType != null) {
        return 'No se pudieron cargar los datos de $dataType desde $provider.';
      }

      if (provider != null) {
        return 'No se pudieron cargar los datos desde $provider.';
      }

      return 'No se pudieron cargar los datos del widget.';
    }

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

  static int? _resolveCount(Map<String, dynamic>? payload) {
    if (payload == null) {
      return null;
    }

    final count = _parseNumber(payload['count']);

    if (count != null) {
      return count.toInt();
    }

    final items = payload['items'];

    if (items is List) {
      return items.length;
    }

    return null;
  }

  static Map<String, dynamic> _resolveCustomConfig(TabWidgetDto widget) {
    final config = Map<String, dynamic>.from(widget.customConfig);

    final timeframe = _stringOrNull(widget.timeframe);

    if (timeframe != null) {
      config['timeframe'] = timeframe;
    }

    return config;
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

  static bool _isErrorStatus(String? value) {
    final normalized = value?.toLowerCase().trim();

    return normalized == 'error' ||
        normalized == 'failed' ||
        normalized == 'failure';
  }

  static bool _isSystemDataWidget(TabWidgetDto widget) {
    final widgetType = widget.widgetType?.toLowerCase().trim();
    final dataType = widget.dataType?.toLowerCase().trim();

    return widgetType == 'system_data' || dataType == 'system_data';
  }

  static String? _resolveSystemDataPrimaryValue(Map<String, dynamic> payload) {
    final firstItem = _firstMapFromItems(payload['items']);

    final agentData =
        _mapOrNull(firstItem?['agent_data']) ??
        _mapOrNull(payload['agent_data']);

    final systemData =
        _mapOrNull(agentData?['system_data']) ??
        _mapOrNull(firstItem?['system_data']) ??
        _mapOrNull(payload['system_data']);

    final machineName = _firstNonEmpty([
      _stringOrNull(firstItem?['machine_name']),
      _stringOrNull(firstItem?['hostname']),
      _stringOrNull(agentData?['machine_name']),
      _stringOrNull(agentData?['hostname']),
      _stringOrNull(systemData?['machine_name']),
      _stringOrNull(systemData?['hostname']),
    ]);

    if (machineName != null) {
      return machineName;
    }

    final system = _stringOrNull(systemData?['system']);
    final release = _stringOrNull(systemData?['release']);

    if (system != null && release != null) {
      return '$system $release';
    }

    final platform = _stringOrNull(systemData?['platform']);

    if (platform != null) {
      return platform;
    }

    return 'Agente activo';
  }

  static Map<String, dynamic>? _mapOrNull(dynamic value) {
    if (value is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(value);
  }

  static bool _isResourceListWidget(TabWidgetDto widget) {
    return widget.widgetType?.toLowerCase().trim() == 'list_resources';
  }

  static bool _isPortsListWidget(TabWidgetDto widget) {
    return widget.widgetType?.toLowerCase().trim() == 'list_ports';
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

  static String _formatPortCount(int count) {
    return count == 1 ? '1 puerto' : '$count puertos';
  }
}
