import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardWidgetItem {
  final String id;
  final String title;
  final WidgetType type;
  final WidgetStatus status;
  final String primaryValue;
  final String? description;
  final int position;

  const DashboardWidgetItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.primaryValue,
    this.description,
    required this.position,
  });

  DashboardWidgetItem copyWith({
    String? id,
    String? title,
    WidgetType? type,
    WidgetStatus? status,
    String? primaryValue,
    String? description,
    int? position,
  }) {
    return DashboardWidgetItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      primaryValue: primaryValue ?? this.primaryValue,
      description: description ?? this.description,
      position: position ?? this.position,
    );
  }
}
