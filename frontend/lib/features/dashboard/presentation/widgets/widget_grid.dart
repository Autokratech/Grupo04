import 'dart:math' as math;

import 'package:frontend/core/utils/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_card.dart';

class WidgetGrid extends StatelessWidget {
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
        const spacing = AppSpacing.md;

        final isMobilePlatform = AppPlatform.isMobile;

        final mobileCardWidth = (constraints.maxWidth - spacing) / 2;

        final cardWidth = isMobilePlatform
            ? math.min(mobileCardWidth, 170.0)
            : 170.0;

        final cardAspectRatio = isMobilePlatform ? 1.05 : 1.2;
        final cardHeight = cardWidth / cardAspectRatio;

        final dragDelay = isMobilePlatform
            ? const Duration(milliseconds: 350)
            : const Duration(milliseconds: 100);

        return SingleChildScrollView(
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
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
                            opacity: 0.85,
                            child: _buildCard(item),
                          ),
                        ),
                      ),
                      childWhenDragging: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: Opacity(opacity: 0.35, child: _buildCard(item)),
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
        );
      },
    );
  }
}
