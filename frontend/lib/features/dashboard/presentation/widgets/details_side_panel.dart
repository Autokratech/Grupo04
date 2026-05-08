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
  final VoidCallback? onDelete;

  const DetailsSidePanel({
    super.key,
    required this.item,
    this.placement = DetailsPanelPlacement.side,
    this.onClose,
    this.showCard = true,
    this.onDelete,
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
          _buildHeader(colorScheme: colorScheme, textTheme: textTheme),
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
          if (hasDescription) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDescriptionSection(
              colorScheme: colorScheme,
              textTheme: textTheme,
              description: description,
            ),
          ],
          if (onDelete != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildDeleteAction(colorScheme: colorScheme),
          ],
        ],
      ),
    );

    if (!showCard) {
      return content;
    }

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.50),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.50),
          width: 2,
        ),
      ),
      child: content,
    );
  }

  Widget _buildHeader({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary),
          ),
          child: Icon(
            _iconForType(item.type),
            color: colorScheme.onPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      WidgetLabels.type(item.type),
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildHeaderStatusBadge(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onClose != null) ...[
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onClose,
            icon: Icon(_closeIconForPlacement(), size: 28),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderStatusBadge({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final statusColor = _statusColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Text(
        WidgetLabels.status(item.status),
        style: textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPrimaryValueSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isInactive = item.status == WidgetStatus.inactive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Valor actual',
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.primaryValue,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: isInactive
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  Widget _buildDescriptionSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String description,
  }) {
    return _buildSectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Descripción',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAction({required ColorScheme colorScheme}) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text('Quitar widget'),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.error,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
