import 'package:frontend/domain/models/widget_type.dart';

class WidgetCatalogItem {
  final String id;
  final String title;
  final WidgetType type;
  final String description;
  final String requirementLabel;

  const WidgetCatalogItem({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.requirementLabel,
  });
}
