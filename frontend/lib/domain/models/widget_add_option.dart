class WidgetAddOption {
  final String label;
  final String providerName;
  final String dataType;
  final Map<String, dynamic> customConfig;

  const WidgetAddOption({
    required this.label,
    required this.providerName,
    required this.dataType,
    this.customConfig = const <String, dynamic>{},
  });
}
