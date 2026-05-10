import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/widget_add_option.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/features/dashboard/presentation/models/add_widget_dialog_result.dart';
import 'package:frontend/features/dashboard/presentation/utils/widget_add_options.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dialogs/add_widget_option_tile.dart';

class AddWidgetDialog extends StatefulWidget {
  final List<WidgetCatalogItem> items;
  final bool Function(WidgetAddOption option) isOptionAlreadyAdded;

  const AddWidgetDialog({
    super.key,
    required this.items,
    required this.isOptionAlreadyAdded,
  });

  @override
  State<AddWidgetDialog> createState() => _AddWidgetDialogState();
}

class _AddWidgetDialogState extends State<AddWidgetDialog> {
  static const double _dialogMaxWidth = 560;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogMaxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg + 32,
                AppSpacing.sm,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: _buildHeader(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Flexible(child: _buildBody()),
                ],
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Icon(
              Icons.add_circle_outline,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Añadir widget',
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Selecciona un widget disponible y una configuración válida.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final visibleItems = widget.items.where((item) {
      final options = optionsForWidgetCatalogItem(item);

      return options.any((option) {
        return !widget.isOptionAlreadyAdded(option);
      });
    }).toList();

    if (visibleItems.isEmpty) {
      return const Center(
        child: Text('No hay widgets disponibles para añadir.'),
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: false,
        radius: const Radius.circular(999),
        thickness: 4,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: ListView.separated(
            controller: _scrollController,
            itemCount: visibleItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return AddWidgetOptionTile(
                item: visibleItems[index],
                isOptionAlreadyAdded: widget.isOptionAlreadyAdded,
                onAddPressed: (item, option) {
                  Navigator.of(
                    context,
                  ).pop(AddWidgetDialogResult(item: item, option: option));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
