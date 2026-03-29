import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardCard extends StatelessWidget {
  final DashboardWidgetItem item;

  const DashboardCard({super.key, required this.item});

  String _buildTypeLabel(WidgetType type) {
    switch (type) {
      case WidgetType.status:
        return 'Estado';
      case WidgetType.metric:
        return 'Métrica';
      case WidgetType.list:
        return 'Alerta';
      case WidgetType.chart:
        return 'Servicio';
    }
  }

  String _buildStatusLabel(WidgetStatus status) {
    switch (status) {
      case WidgetStatus.ok:
        return 'OK';
      case WidgetStatus.error:
        return 'Error';
      case WidgetStatus.inactive:
        return 'Inactivo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              item.primaryValue,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(_buildTypeLabel(item.type)),
                const SizedBox(width: 12),
                Text(_buildStatusLabel(item.status)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}