import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:frontend/features/dashboard/presentation/utils/widget_labels.dart';
import 'package:frontend/features/dashboard/presentation/widgets/provider_logo.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(14);
    final statusColor = _buildStatusColor(item.status);
    final isInactive = item.status == WidgetStatus.inactive;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.04)
            : colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : statusColor.withValues(alpha: isInactive ? 0.18 : 0.10),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.14 : 0.07),
            blurRadius: isSelected ? 8 : 2,
            offset: Offset(0, isSelected ? 10 : 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            hoverColor: AppColors.primary.withValues(alpha: 0.04),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: AppColors.primary.withValues(alpha: 0.03),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxWidth <= 180 || constraints.maxHeight <= 150;

                final isMobile = AppPlatform.isMobile;

                final textTheme = Theme.of(context).textTheme;
                final titleStyle = isCompact
                    ? textTheme.titleSmall
                    : textTheme.titleMedium;
                final valueStyle = isCompact
                    ? textTheme.titleLarge
                    : textTheme.headlineSmall;
                final labelStyle = textTheme.labelMedium;

                final padding = isCompact ? AppSpacing.sm : AppSpacing.md;

                return Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(
                        isCompact: isCompact,
                        titleStyle: titleStyle,
                        statusColor: statusColor,
                      ),
                      SizedBox(
                        height: isCompact ? AppSpacing.xs : AppSpacing.sm,
                      ),
                      if (isMobile)
                        Expanded(
                          child: Center(
                            child: Text(
                              item.primaryValue,
                              textAlign: TextAlign.center,
                              style: valueStyle?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                color: isInactive ? AppColors.textSecondary : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      else ...[
                        Center(
                          child: Text(
                            item.primaryValue,
                            textAlign: TextAlign.center,
                            style: valueStyle?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              color: isInactive ? AppColors.textSecondary : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                      ],
                      _buildFooter(
                        isCompact: isCompact,
                        labelStyle: labelStyle,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isCompact,
    required TextStyle? titleStyle,
    required Color statusColor,
  }) {
    final iconBoxSize = isCompact ? 30.0 : 34.0;
    final iconSize = isCompact ? 17.0 : 20.0;
    final hasProvider = item.provider != null && item.provider!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _buildTypeIcon(item.type),
            size: iconSize,
            color: statusColor,
          ),
        ),
        SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
        Expanded(
          child: Text(
            item.title,
            style: titleStyle?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasProvider) ...[
          SizedBox(width: isCompact ? 6 : AppSpacing.sm),
          _buildProviderBadge(isCompact: isCompact),
        ],
      ],
    );
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

  Widget _buildProviderBadge({required bool isCompact}) {
    final size = isCompact ? 18.0 : 22.0;

    return Container(
      width: isCompact ? 28 : 32,
      height: isCompact ? 28 : 32,
      padding: EdgeInsets.all(isCompact ? 5 : 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.10),
        ),
      ),
      child: ProviderLogo(
        provider: item.provider,
        size: size,
      ),
    );
  }

  Widget _buildFooter({
    required bool isCompact,
    required TextStyle? labelStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            WidgetLabels.type(item.type),
            style: labelStyle?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
        _buildStatusChip(labelStyle: labelStyle, compact: isCompact),
      ],
    );
  }

  Widget _buildStatusChip({
    required TextStyle? labelStyle,
    required bool compact,
  }) {
    final statusColor = _buildStatusColor(item.status);
    final isInactive = item.status == WidgetStatus.inactive;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: isInactive ? 0.06 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: statusColor.withValues(alpha: isInactive ? 0.30 : 0.18),
        ),
      ),
      child: Text(
        WidgetLabels.status(item.status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: labelStyle?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }

  IconData _buildTypeIcon(WidgetType type) {
    switch (type) {
      case WidgetType.metric:
        return Icons.speed_outlined;
      case WidgetType.list:
        return Icons.format_list_bulleted_rounded;
      case WidgetType.chart:
        return Icons.insert_chart_outlined_rounded;
      case WidgetType.service:
        return Icons.cloud_queue_rounded;
      case WidgetType.alert:
        return Icons.warning_amber_rounded;
      case WidgetType.status:
        return Icons.radio_button_checked_rounded;
      case WidgetType.pipeline:
        return Icons.radio_button_checked_rounded;
      case WidgetType.issue:
        return Icons.radio_button_checked_rounded;
    }
  }
}
