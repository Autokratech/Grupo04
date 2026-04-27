import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';

class DashboardTabSelector extends StatelessWidget {
  final List<DashboardTab> tabs;
  final DashboardTab selectedTab;
  final bool canCreateTab;
  final ValueChanged<DashboardTab> onTabChanged;
  final VoidCallback onCreateTabPressed;

  const DashboardTabSelector({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.canCreateTab,
    required this.onTabChanged,
    required this.onCreateTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            ChoiceChip(
              label: Text(tab.name),
              selected: selectedTab.id == tab.id,
              onSelected: (_) => onTabChanged(tab),
            ),
            const SizedBox(width: 8),
          ],
          IconButton.filledTonal(
            onPressed: canCreateTab ? onCreateTabPressed : null,
            tooltip: canCreateTab
                ? 'Crear pestaña'
                : 'No se pueden crear más pestañas',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
