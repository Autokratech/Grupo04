import 'package:frontend/domain/models/widget_type.dart';

class WidgetCatalogItem {
  final String id;
  final String title;
  final WidgetType type;
  final String description;
  final String metadataLabel;
  final String? provider;
  final String? dataType;
  final Map<String, dynamic> customConfig;

  const WidgetCatalogItem({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.metadataLabel,
    this.provider,
    this.dataType,
    this.customConfig = const {},
  });

  bool get canBeCreatedRemotely {
    return id.trim().isNotEmpty &&
        provider != null &&
        provider!.trim().isNotEmpty &&
        dataType != null &&
        dataType!.trim().isNotEmpty;
  }
}
