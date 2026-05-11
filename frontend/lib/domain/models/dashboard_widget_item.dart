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
  final String? provider;
  final String? dataType;
  final DateTime? updatedAt;
  final int? ttl;
  final int? count;
  final Map<String, dynamic>? rawData;
  final Map<String, dynamic>? customConfig;

  const DashboardWidgetItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.primaryValue,
    this.description,
    required this.position,
    this.provider,
    this.dataType,
    this.updatedAt,
    this.ttl,
    this.count,
    this.rawData,
    this.customConfig,
  });

  DashboardWidgetItem copyWith({
    String? id,
    String? title,
    WidgetType? type,
    WidgetStatus? status,
    String? primaryValue,
    String? description,
    int? position,
    String? provider,
    String? dataType,
    DateTime? updatedAt,
    int? ttl,
    int? count,
    Map<String, dynamic>? rawData,
    Map<String, dynamic>? customConfig,
  }) {
    return DashboardWidgetItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      primaryValue: primaryValue ?? this.primaryValue,
      description: description ?? this.description,
      position: position ?? this.position,
      provider: provider ?? this.provider,
      dataType: dataType ?? this.dataType,
      updatedAt: updatedAt ?? this.updatedAt,
      ttl: ttl ?? this.ttl,
      count: count ?? this.count,
      rawData: rawData ?? this.rawData,
      customConfig: customConfig ?? this.customConfig,
    );
  }
}