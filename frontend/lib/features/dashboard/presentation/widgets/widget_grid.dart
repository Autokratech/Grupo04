import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_card.dart';

class WidgetGrid extends StatelessWidget {
  final List<DashboardWidgetItem> items;

  const WidgetGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return DashboardCard(item: item);
      },
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
    );
  }
}
