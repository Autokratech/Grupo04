import 'package:frontend/data/models/dto/dashboard_dtos/widget_field_dto.dart';

class TabWidgetDto {
  final String tabWidgetId;
  final String? widgetTitle;
  final String? widgetType;
  final int? widgetIndex;
  final String? dataType;
  final Map<String, dynamic> customConfig;
  final List<WidgetFieldDto> widgetFields;

  TabWidgetDto({
    required this.tabWidgetId,
    required this.widgetTitle,
    required this.widgetType,
    required this.widgetIndex,
    required this.dataType,
    required this.customConfig,
    required this.widgetFields,
  });

  factory TabWidgetDto.fromMap(Map<String, dynamic> map) {
    return TabWidgetDto(
      tabWidgetId: map['tab_widget_id']?.toString() ?? '',
      widgetTitle: map['widget_title']?.toString(),
      widgetType: map['widget_type']?.toString(),
      widgetIndex: _parseInt(map['widget_index']),
      dataType: map['data_type']?.toString(),
      customConfig: _parseMap(map['custom_config']),
      widgetFields: _parseList(map['widget_fields'], WidgetFieldDto.fromMap),
    );
  }
}

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

Map<String, dynamic> _parseMap(dynamic value) {
  if (value is! Map) {
    return {};
  }

  return Map<String, dynamic>.from(value);
}

List<T> _parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic> map) fromMap,
) {
  if (value is! List) {
    return [];
  }

  return value
      .whereType<Map>()
      .map((item) => fromMap(Map<String, dynamic>.from(item)))
      .toList();
}
