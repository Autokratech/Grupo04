import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
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
        return 'Lista';
      case WidgetType.chart:
        return 'Gráfico';
      case WidgetType.service:
        return 'Servicio';
      case WidgetType.alert:
        return 'Alerta';
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

  Color _buildStatusColor(WidgetStatus status) {
    switch (status) {
      case WidgetStatus.ok:
        return AppColors.success;
      case WidgetStatus.error:
        return AppColors.error;
      case WidgetStatus.inactive:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              item.primaryValue,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Text(_buildTypeLabel(item.type)),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _buildStatusColor(item.status).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _buildStatusLabel(item.status),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _buildStatusColor(item.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
