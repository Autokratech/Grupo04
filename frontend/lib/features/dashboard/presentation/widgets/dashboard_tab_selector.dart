import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';

class DashboardTabSelector extends StatelessWidget {
  static const double _selectedTabMaxWidth = 120;
  static const double _unselectedTabMaxWidth = 140;
  static const double _actionsButtonSize = 20;
  static const double _actionsIconSize = 16;
  static const double _createButtonSize = 30;
  static const double _createIconSize = 18;

  static const Duration _desktopDragDelay = Duration(milliseconds: 450);
  static const Duration _mobileDragDelay = Duration(milliseconds: 650);

  final List<DashboardTab> tabs;
  final DashboardTab selectedTab;
  final bool canCreateTab;
  final ValueChanged<DashboardTab> onTabChanged;
  final VoidCallback onCreateTabPressed;
  final ValueChanged<DashboardTab> onRenameTabPressed;
  final bool canDeleteTab;
  final ValueChanged<DashboardTab> onDeleteTabPressed;
  final ValueChanged<List<DashboardTab>> onTabsReordered;

  const DashboardTabSelector({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.canCreateTab,
    required this.onTabChanged,
    required this.onCreateTabPressed,
    required this.onRenameTabPressed,
    required this.canDeleteTab,
    required this.onDeleteTabPressed,
    required this.onTabsReordered,
  });

  void _toggleMenu(MenuController controller) {
    if (controller.isOpen) {
      controller.close();
      return;
    }

    controller.open();
  }

  List<DashboardTab> _moveTab({
    required DashboardTab draggedTab,
    required DashboardTab targetTab,
  }) {
    if (draggedTab.id == targetTab.id) {
      return tabs;
    }

    final reorderedTabs = [...tabs];

    final oldIndex = reorderedTabs.indexWhere((tab) => tab.id == draggedTab.id);

    final targetIndex = reorderedTabs.indexWhere(
      (tab) => tab.id == targetTab.id,
    );

    if (oldIndex == -1 || targetIndex == -1) {
      return tabs;
    }

    final removedTab = reorderedTabs.removeAt(oldIndex);
    reorderedTabs.insert(targetIndex, removedTab);

    return reorderedTabs;
  }

  bool _hasSameOrder(List<DashboardTab> newTabs) {
    if (newTabs.length != tabs.length) {
      return false;
    }

    for (var index = 0; index < tabs.length; index++) {
      if (tabs[index].id != newTabs[index].id) {
        return false;
      }
    }

    return true;
  }

  Widget _buildTabChip(BuildContext context, DashboardTab tab) {
    final isSelected = selectedTab.id == tab.id;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.secondaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            onTabChanged(tab);
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.sm,
            right: isSelected ? 4 : AppSpacing.sm,
            top: 6,
            bottom: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSelected
                      ? _selectedTabMaxWidth
                      : _unselectedTabMaxWidth,
                ),
                child: Text(
                  tab.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 2),
                _buildTabActionsMenu(tab),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabActionsMenu(DashboardTab tab) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.edit_outlined),
          onPressed: () => onRenameTabPressed(tab),
          child: const Text('Renombrar'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.delete_outline),
          onPressed: canDeleteTab ? () => onDeleteTabPressed(tab) : null,
          child: const Text('Eliminar'),
        ),
      ],
      builder: (context, controller, child) {
        return Tooltip(
          message: 'Opciones del dashboard',
          child: InkResponse(
            radius: 14,
            onTap: () => _toggleMenu(controller),
            child: const SizedBox(
              width: _actionsButtonSize,
              height: _actionsButtonSize,
              child: Icon(Icons.more_vert, size: _actionsIconSize),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTab(DashboardTab tab) {
    final dragDelay = AppPlatform.isMobile
        ? _mobileDragDelay
        : _desktopDragDelay;

    return DragTarget<DashboardTab>(
      onWillAcceptWithDetails: (details) {
        return details.data.id != tab.id;
      },
      onAcceptWithDetails: (details) {
        final reorderedTabs = _moveTab(
          draggedTab: details.data,
          targetTab: tab,
        );

        if (_hasSameOrder(reorderedTabs)) return;

        onTabsReordered(reorderedTabs);
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<DashboardTab>(
          data: tab,
          delay: dragDelay,
          feedback: Material(
            color: Colors.transparent,
            child: _buildTabChip(context, tab),
          ),
          childWhenDragging: Opacity(
            opacity: 0.35,
            child: _buildTabChip(context, tab),
          ),
          child: _buildTabChip(context, tab),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            _buildDraggableTab(tab),
            const SizedBox(width: AppSpacing.sm),
          ],
          Tooltip(
            message: canCreateTab
                ? 'Crear dashboard'
                : 'No se pueden crear más dashboards',
            child: FilledButton.tonal(
              onPressed: canCreateTab ? onCreateTabPressed : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(_createButtonSize, _createButtonSize),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Icon(Icons.add, size: _createIconSize),
            ),
          ),
        ],
      ),
    );
  }
}
