import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';

class DashboardCard extends StatelessWidget {
  final DashboardWidgetItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onTap,
  });

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
      case WidgetType.pipeline:
        return 'Pipeline';
      case WidgetType.issue:
        return 'Issue';
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

  Widget _buildFooter({
    required bool isCompact,
    required TextStyle? labelStyle,
    required BorderRadius borderRadius,
  }) {
    return Row(
      children: [
        Flexible(
          child: Text(
            _buildTypeLabel(item.type),
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
        _buildStatusChip(
          labelStyle: labelStyle,
          borderRadius: borderRadius,
          compact: isCompact,
        ),
      ],
    );
  }

  Widget _buildStatusChip({
    required TextStyle? labelStyle,
    required BorderRadius borderRadius,
    required bool compact,
  }) {
    final statusColor = _buildStatusColor(item.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: borderRadius,
      ),
      child: Text(
        _buildStatusLabel(item.status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: labelStyle?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxWidth <= 180 || constraints.maxHeight <= 150;

            final textTheme = Theme.of(context).textTheme;
            final titleStyle = isCompact
                ? textTheme.titleSmall
                : textTheme.titleMedium;
            final valueStyle = isCompact
                ? textTheme.titleLarge
                : textTheme.headlineSmall;
            final labelStyle = isCompact
                ? textTheme.titleSmall
                : textTheme.labelMedium;

            return Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.primaryValue,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  _buildFooter(
                    isCompact: isCompact,
                    labelStyle: labelStyle,
                    borderRadius: borderRadius,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
