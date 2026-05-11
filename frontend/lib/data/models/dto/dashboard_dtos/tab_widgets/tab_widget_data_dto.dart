class TabWidgetDataDto {
  final String tabWidgetId;
  final String? providerTag;
  final String? status;
  final DateTime? timestamp;
  final int? ttl;
  final Map<String, dynamic>? data;

  const TabWidgetDataDto({
    required this.tabWidgetId,
    required this.providerTag,
    required this.status,
    required this.timestamp,
    required this.ttl,
    required this.data,
  });

  factory TabWidgetDataDto.fromMap(Map<String, dynamic> map) {
    return TabWidgetDataDto(
      tabWidgetId: map['tab_widget_id']?.toString() ?? '',
      providerTag: map['provider_tag']?.toString(),
      status: map['status']?.toString(),
      timestamp: _parseDateTime(map['timestamp']),
      ttl: _parseInt(map['ttl']),
      data: _parseMap(map['data']),
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) {
    return null;
  }

  return DateTime.tryParse(value);
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

Map<String, dynamic>? _parseMap(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is! Map) {
    return null;
  }

  return Map<String, dynamic>.from(value);
}
