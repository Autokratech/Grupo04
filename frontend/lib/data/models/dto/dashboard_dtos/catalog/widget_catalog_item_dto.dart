class WidgetCatalogItemDto {
  final String id;
  final String? type;
  final String? name;
  final String? description;
  final String? function;
  final List<dynamic> dataTypes;

  const WidgetCatalogItemDto({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.function,
    required this.dataTypes,
  });

  factory WidgetCatalogItemDto.fromMap(Map<String, dynamic> map) {
    return WidgetCatalogItemDto(
      id: map['widget_id']?.toString() ?? '',
      type: map['widget_type']?.toString(),
      name: map['widget_name']?.toString(),
      description: map['widget_description']?.toString(),
      function: map['widget_function']?.toString(),
      dataTypes: _parseList(map['widget_data_types']),
    );
  }
}

List<dynamic> _parseList(dynamic value) {
  if (value is List) {
    return value;
  }

  return const [];
}
