import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/widget_add_option.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/domain/models/widget_type.dart';
import 'package:frontend/features/dashboard/presentation/utils/widget_add_options.dart';
import 'package:frontend/features/dashboard/presentation/utils/widget_labels.dart';
import 'package:frontend/features/dashboard/presentation/widgets/provider_logo.dart';

class AddWidgetOptionTile extends StatefulWidget {
  final WidgetCatalogItem item;
  final bool Function(WidgetAddOption option) isOptionAlreadyAdded;
  final void Function(WidgetCatalogItem item, WidgetAddOption option)
  onAddPressed;

  const AddWidgetOptionTile({
    super.key,
    required this.item,
    required this.isOptionAlreadyAdded,
    required this.onAddPressed,
  });

  @override
  State<AddWidgetOptionTile> createState() => _AddWidgetOptionTileState();
}

class _AddWidgetOptionTileState extends State<AddWidgetOptionTile> {
  late final List<WidgetAddOption> _options;
  WidgetAddOption? _selectedOption;

  @override
  void initState() {
    super.initState();

    _options = optionsForWidgetCatalogItem(widget.item).where((option) {
      return !widget.isOptionAlreadyAdded(option);
    }).toList();

    if (_options.isNotEmpty) {
      _selectedOption = _options.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNarrow = MediaQuery.sizeOf(context).width < 460;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 2,
        ),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainContent(context),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAddButton(),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildMainContent(context)),
                const SizedBox(width: AppSpacing.md),
                _buildAddButton(),
              ],
            ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasProvider =
        widget.item.provider != null && widget.item.provider!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          padding: EdgeInsets.all(hasProvider ? 7 : 0),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: hasProvider
              ? ProviderLogo(provider: widget.item.provider, size: 22)
              : Icon(
                  _iconForType(widget.item.type),
                  color: colorScheme.primary,
                  size: 22,
                ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildTypeBadge(context),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.item.description,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.item.metadataLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildOptionSelector(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSelector(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_options.isEmpty) {
      return Text(
        'Configuración no disponible todavía.',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.error,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    if (_options.length == 1) {
      return Text(
        _options.first.label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return DropdownButtonFormField<WidgetAddOption>(
      initialValue: _selectedOption,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Configuración',
        isDense: true,
      ),
      items: _options.map((option) {
        return DropdownMenuItem<WidgetAddOption>(
          value: option,
          child: Text(option.label),
        );
      }).toList(),
      onChanged: (option) {
        if (option == null) return;

        setState(() {
          _selectedOption = option;
        });
      },
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Text(
        WidgetLabels.type(widget.item.type),
        style: textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final selectedOption = _selectedOption;

    return FilledButton.tonalIcon(
      onPressed: selectedOption == null
          ? null
          : () {
              widget.onAddPressed(widget.item, selectedOption);
            },
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Añadir'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
