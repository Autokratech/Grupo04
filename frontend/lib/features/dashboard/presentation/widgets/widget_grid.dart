import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_card.dart';

class WidgetGrid extends StatelessWidget {
  static const double _maxCardWidth = 170;
  static const double _mobileCardAspectRatio = 1.05;
  static const double _desktopCardAspectRatio = 1.2;

  static const double _dragFeedbackOpacity = 0.85;
  static const double _draggingChildOpacity = 0.35;

  static const Duration _mobileDragDelay = Duration(milliseconds: 650);
  static const Duration _desktopDragDelay = Duration(milliseconds: 450);

  final List<DashboardWidgetItem> items;
  final DashboardWidgetItem? selectedItem;
  final ValueChanged<DashboardWidgetItem> onItemSelected;
  final ValueChanged<List<DashboardWidgetItem>> onItemsReordered;
  final bool canAddWidget;
  final VoidCallback? onAddWidgetPressed;

  const WidgetGrid({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onItemsReordered,
    this.canAddWidget = false,
    this.onAddWidgetPressed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = AppSpacing.md;

        final isMobile = AppPlatform.isMobile;
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        final double mobileCardWidth = math.max(
          0.0,
          (availableWidth - spacing) / 2,
        );

        final double preferredCardWidth = isMobile && !isLandscape
            ? mobileCardWidth
            : _maxCardWidth;

        final double cardWidth = math.min(preferredCardWidth, availableWidth);

        final cardAspectRatio = isMobile
            ? _mobileCardAspectRatio
            : _desktopCardAspectRatio;

        final double cardHeight = cardWidth / cardAspectRatio;

        final dragDelay = isMobile ? _mobileDragDelay : _desktopDragDelay;

        final shouldCenterGrid = isMobile && isLandscape;

        final columns = math.max(
          1,
          ((availableWidth + spacing) / (cardWidth + spacing)).floor(),
        );

        final double gridWidth =
            (columns * cardWidth) + ((columns - 1) * spacing);

        final grid = Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: [
            for (final item in items)
              DragTarget<DashboardWidgetItem>(
                onWillAcceptWithDetails: (details) {
                  return details.data.id != item.id;
                },
                onAcceptWithDetails: (details) {
                  final reorderedItems = _moveItem(
                    draggedItem: details.data,
                    targetItem: item,
                  );

                  if (_hasSameOrder(reorderedItems)) return;

                  onItemsReordered(reorderedItems);
                },
                builder: (context, candidateData, rejectedData) {
                  return LongPressDraggable<DashboardWidgetItem>(
                    data: item,
                    delay: dragDelay,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: Opacity(
                          opacity: _dragFeedbackOpacity,
                          child: _buildCard(item),
                        ),
                      ),
                    ),
                    childWhenDragging: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Opacity(
                        opacity: _draggingChildOpacity,
                        child: _buildCard(item),
                      ),
                    ),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _buildCard(item),
                    ),
                  );
                },
              ),
            if (canAddWidget && onAddWidgetPressed != null)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _buildAddWidgetCard(context),
              ),
          ],
        );

        return SingleChildScrollView(
          child: shouldCenterGrid
              ? Center(
                  child: SizedBox(width: gridWidth, child: grid),
                )
              : SizedBox(width: double.infinity, child: grid),
        );
      },
    );
  }

  List<DashboardWidgetItem> _moveItem({
    required DashboardWidgetItem draggedItem,
    required DashboardWidgetItem targetItem,
  }) {
    if (draggedItem.id == targetItem.id) {
      return items;
    }

    final reorderedItems = [...items];

    final oldIndex = reorderedItems.indexWhere(
      (item) => item.id == draggedItem.id,
    );

    final targetIndex = reorderedItems.indexWhere(
      (item) => item.id == targetItem.id,
    );

    if (oldIndex == -1 || targetIndex == -1) {
      return items;
    }

    final removedItem = reorderedItems.removeAt(oldIndex);

    reorderedItems.insert(targetIndex, removedItem);

    return reorderedItems;
  }

  Widget _buildCard(DashboardWidgetItem item) {
    return DashboardCard(
      item: item,
      isSelected: selectedItem?.id == item.id,
      onTap: () {
        onItemSelected(item);
      },
    );
  }

  Widget _buildAddWidgetCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onAddWidgetPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Añadir widget',
                textAlign: TextAlign.center,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSameOrder(List<DashboardWidgetItem> newItems) {
    if (newItems.length != items.length) {
      return false;
    }

    for (var index = 0; index < items.length; index++) {
      if (items[index].id != newItems[index].id) {
        return false;
      }
    }

    return true;
  }
}
