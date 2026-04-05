import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DetailsSidePanel extends StatelessWidget {
  final DashboardWidgetItem item;

  const DetailsSidePanel({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String? description = item.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles', style: Theme.of(context).textTheme.titleMedium),
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Valor: ${item.primaryValue}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Estado: ${_buildStatusLabel(item.status)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Tipo: ${_buildTypeLabel(item.type)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (hasDescription) ...[
              Text(
                'Descripción: ${item.description}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
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

  String _buildTypeLabel(WidgetType type) {
    switch (type) {
      case WidgetType.status:
        return 'Estado';
      case WidgetType.metric:
        return 'Métrica';
      case WidgetType.list:
        return 'Lista';
      case WidgetType.chart:
        return 'Gráfico';
      case WidgetType.service:
        return 'Servicio';
      case WidgetType.alert:
        return 'Alerta';
    }
  }
}
