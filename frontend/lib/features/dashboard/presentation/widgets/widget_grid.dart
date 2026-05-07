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
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem?.id == item.id;

        return DashboardCard(
          item: item,
          isSelected: isSelected,
          onTap: () {
            onItemSelected(item);
          },
        );
      },
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.sm),
    );
  }
}
