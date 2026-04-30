import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';

class DashboardTabSelector extends StatelessWidget {
  final List<DashboardTab> tabs;
  final DashboardTab selectedTab;
  final bool canCreateTab;
  final ValueChanged<DashboardTab> onTabChanged;
  final VoidCallback onCreateTabPressed;
  final bool canDeleteTab;
  final ValueChanged<DashboardTab> onDeleteTabPressed;

  const DashboardTabSelector({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.canCreateTab,
    required this.onTabChanged,
    required this.onCreateTabPressed,
    required this.canDeleteTab,
    required this.onDeleteTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            InputChip(
              showCheckmark: false,
              label: Text(tab.name),
              selected: selectedTab.id == tab.id,
              onSelected: selectedTab.id == tab.id
                  ? null
                  : (_) => onTabChanged(tab),
              onDeleted: canDeleteTab && tab.id == selectedTab.id
                  ? () => onDeleteTabPressed(tab)
                  : null,
              deleteIcon: const Icon(Icons.close, size: 14),
              deleteButtonTooltipMessage: 'Eliminar dashboard',
            ),
            const SizedBox(width: 8),
          ],
          Tooltip(
            message: canCreateTab
                ? 'Crear dashboard'
                : 'No se pueden crear más dashboards',
            child: FilledButton.tonal(
              onPressed: canCreateTab ? onCreateTabPressed : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(30, 30),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
