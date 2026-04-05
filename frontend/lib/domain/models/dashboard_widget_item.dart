import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardWidgetItem {
  final String id;
  final String title;
  final WidgetType type;
  final WidgetStatus status;
  final String primaryValue;
  final String? description;

  const DashboardWidgetItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.primaryValue,
    this.description,
  });
}
