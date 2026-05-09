class WidgetCatalogItemDto {
  final String id;
  final String? type;
  final String? name;
  final String? description;
  final String? function;

  const WidgetCatalogItemDto({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.function,
  });

  factory WidgetCatalogItemDto.fromMap(Map<String, dynamic> map) {
    return WidgetCatalogItemDto(
      id: map['widget_id']?.toString() ?? '',
      type: map['widget_type']?.toString(),
      name: map['widget_name']?.toString(),
      description: map['widget_description']?.toString(),
      function: map['widget_function']?.toString(),
    );
  }
}
