import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/domain/models/widget_status.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:frontend/features/dashboard/presentation/utils/widget_labels.dart';

enum DetailsPanelPlacement { side, bottom }

class DetailsSidePanel extends StatelessWidget {
  final DashboardWidgetItem item;
  final DetailsPanelPlacement placement;
  final VoidCallback? onClose;
  final bool showCard;

  const DetailsSidePanel({
    super.key,
    required this.item,
    this.placement = DetailsPanelPlacement.side,
    this.onClose,
    this.showCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final description = item.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    final content = SingleChildScrollView(
      primary: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPrimaryValueSection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          if (item.status == WidgetStatus.inactive) ...[
            const SizedBox(height: AppSpacing.md),
            _buildMissingDataNotice(
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildMetadataSection(
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDescriptionSection(
              colorScheme: colorScheme,
              textTheme: textTheme,
              description: description,
            ),
          ],
        ],
      ),
    );

    if (!showCard) {
      return content;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: content,
    );
  }

  Widget _buildHeader({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _iconForType(item.type),
            color: colorScheme.onPrimaryContainer,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles del widget',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (onClose != null) ...[
          IconButton(
            onPressed: onClose,
            icon: Icon(
              _closeIconForPlacement(),
              size: 28,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryValueSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Valor actual',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.primaryValue,
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingDataNotice({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.tertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Este widget todavía no tiene datos. Conecta un proveedor OAuth o registra un agente para empezar a recibir métricas.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _buildInfoChip(
          colorScheme: colorScheme,
          textTheme: textTheme,
          icon: Icons.label,
          value: WidgetLabels.type(item.type),
        ),
        _buildStatusBadge(colorScheme: colorScheme, textTheme: textTheme),
      ],
    );
  }

  Widget _buildInfoChip({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'Tipo: ',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final statusColor = _statusColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: item.status == WidgetStatus.inactive
            ? Border.all(color: statusColor.withValues(alpha: 0.35))
            : null,
      ),
      child: Text(
        WidgetLabels.status(item.status),
        style: textTheme.labelMedium?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDescriptionSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  IconData _closeIconForPlacement() {
    switch (placement) {
      case DetailsPanelPlacement.side:
        return Icons.keyboard_arrow_right;
      case DetailsPanelPlacement.bottom:
        return Icons.keyboard_arrow_down;
    }
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (item.status) {
      case WidgetStatus.ok:
        return AppColors.success;
      case WidgetStatus.error:
        return AppColors.error;
      case WidgetStatus.inactive:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _iconForType(WidgetType type) {
    switch (type) {
      case WidgetType.status:
        return Icons.check_circle_outline;
      case WidgetType.metric:
        return Icons.speed_outlined;
      case WidgetType.list:
        return Icons.list_alt_outlined;
      case WidgetType.chart:
        return Icons.insert_chart_outlined;
      case WidgetType.service:
        return Icons.dns_outlined;
      case WidgetType.alert:
        return Icons.warning_amber_outlined;
      case WidgetType.pipeline:
        return Icons.account_tree_outlined;
      case WidgetType.issue:
        return Icons.bug_report_outlined;
    }
  }
}
