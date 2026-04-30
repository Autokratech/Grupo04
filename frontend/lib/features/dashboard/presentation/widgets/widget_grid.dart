import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_card.dart';

class WidgetGrid extends StatelessWidget {
  final List<DashboardWidgetItem> items;
  final DashboardWidgetItem? selectedItem;
  final ValueChanged<DashboardWidgetItem> onItemSelected;

  const WidgetGrid({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    const cardWidth = 200.0;
    const cardAspectRatio = 1.2;
    const cardHeight = cardWidth / cardAspectRatio;

    return SingleChildScrollView(
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final item in items)
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: DashboardCard(
                item: item,
                isSelected: selectedItem?.id == item.id,
                onTap: () {
                  onItemSelected(item);
                },
              ),
            ),
        ],
      ),
    );
  }
}
