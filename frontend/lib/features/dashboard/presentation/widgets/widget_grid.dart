import 'dart:math' as math;
import 'package:frontend/core/utils/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
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

  const WidgetGrid({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    required this.onItemsReordered,
  });

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = AppSpacing.md;

        final mobileCardWidth = (availableWidth - spacing) / 2;

        final preferredCardWidth = AppPlatform.isMobile
            ? math.min(mobileCardWidth, _maxCardWidth)
            : _maxCardWidth;

        final cardWidth = math.min(preferredCardWidth, availableWidth);

        final cardAspectRatio = AppPlatform.isMobile
            ? _mobileCardAspectRatio
            : _desktopCardAspectRatio;
        final cardHeight = cardWidth / cardAspectRatio;

        final dragDelay = AppPlatform.isMobile
            ? _mobileDragDelay
            : _desktopDragDelay;

        final columns = math.max(
          1,
          ((availableWidth + spacing) / (cardWidth + spacing)).floor(),
        );

        final gridWidth = (columns * cardWidth) + ((columns - 1) * spacing);

        return SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: gridWidth,
              child: Wrap(
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
