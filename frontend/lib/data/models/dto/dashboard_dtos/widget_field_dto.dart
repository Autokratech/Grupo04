class WidgetFieldDto {
  final String? key;
  final String? label;
  final String? type;
  final bool primary;

  const WidgetFieldDto({
    required this.key,
    required this.label,
    required this.type,
    required this.primary,
  });

  factory WidgetFieldDto.fromMap(Map<String, dynamic> map) {
    return WidgetFieldDto(
      key: map['key']?.toString(),
      label: map['label']?.toString(),
      type: map['type']?.toString(),
      primary: map['primary'] == true,
    );
  }
}
