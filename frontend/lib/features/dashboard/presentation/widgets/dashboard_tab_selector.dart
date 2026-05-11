import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';

class DashboardTabSelector extends StatelessWidget {
  static const double _selectedTabMaxWidth = 200;
  static const double _unselectedTabMaxWidth = 150;
  static const double _actionsButtonSize = 26;
  static const double _actionsIconSize = 17;
  static const double _createButtonSize = 26;
  static const double _createIconSize = 15;
  static const double _tabMinHeight = 38;

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs) ...[
            KeyedSubtree(key: ValueKey(tab.id), child: _buildDraggableTab(tab)),
            const SizedBox(width: AppSpacing.sm),
          ],
          Builder(
            builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;

              return Tooltip(
                message: canCreateTab
                    ? 'Crear dashboard'
                    : 'No se pueden crear más dashboards',
                child: Material(
                  color: canCreateTab
                      ? AppColors.primary.withValues(alpha: 0.04)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.60,
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: canCreateTab
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : colorScheme.outlineVariant.withValues(alpha: 0.60),
                      width: 1.2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: canCreateTab ? onCreateTabPressed : null,
                    hoverColor: AppColors.primary.withValues(alpha: 0.06),
                    splashColor: AppColors.primary.withValues(alpha: 0.10),
                    highlightColor: AppColors.primary.withValues(alpha: 0.04),
                    child: SizedBox(
                      width: _createButtonSize,
                      height: _createButtonSize,
                      child: Icon(
                        Icons.add_rounded,
                        size: _createIconSize,
                        color: canCreateTab
                            ? AppColors.primary
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.45,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.18)
        : AppColors.secondary.withValues(alpha: 0.05);

    final borderColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.55)
        : AppColors.secondary.withValues(alpha: 0.20);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: _tabMinHeight),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              onTabChanged(tab);
            }
          },
          hoverColor: isSelected
              ? colorScheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.sm,
              right: isSelected ? 4 : AppSpacing.sm,
              top: 7,
              bottom: 7,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  _buildTabIndicator(colorScheme: colorScheme),
                  const SizedBox(width: AppSpacing.sm),
                ],
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
                    style: textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _buildTabActionsMenu(context, tab),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIndicator({required ColorScheme colorScheme}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTabActionsMenu(BuildContext context, DashboardTab tab) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
        surfaceTintColor: WidgetStatePropertyAll(
          AppColors.secondary.withValues(alpha: 0.2),
        ),
        elevation: const WidgetStatePropertyAll(4),
        shadowColor: WidgetStatePropertyAll(
          colorScheme.shadow.withValues(alpha: 0.4),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.28),
              width: 1.4,
            ),
          ),
        ),
      ),
      menuChildren: [
        SizedBox(
          width: 120,
          child: MenuItemButton(
            leadingIcon: const Icon(Icons.edit_outlined, size: 18),
            style: _menuItemStyle(colorScheme: colorScheme, danger: false),
            onPressed: () => onRenameTabPressed(tab),
            child: Text(
              'Renombrar',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 120,
          child: MenuItemButton(
            leadingIcon: const Icon(Icons.delete_outline, size: 18),
            style: _menuItemStyle(colorScheme: colorScheme, danger: true),
            onPressed: canDeleteTab ? () => onDeleteTabPressed(tab) : null,
            child: Text(
              'Eliminar',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return InkResponse(
          radius: 16,
          onTap: () => _toggleMenu(controller),
          hoverColor: colorScheme.primary.withValues(alpha: 0.08),
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: colorScheme.primary.withValues(alpha: 0.10),
          child: SizedBox(
            width: _actionsButtonSize,
            height: _actionsButtonSize,
            child: Icon(
              Icons.more_vert_rounded,
              size: _actionsIconSize,
              color: colorScheme.primary,
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _menuItemStyle({
    required ColorScheme colorScheme,
    required bool danger,
  }) {
    final baseColor = danger ? colorScheme.error : AppColors.primary;

    return ButtonStyle(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.42);
        }

        return danger ? colorScheme.error : colorScheme.onSurface;
      }),
      iconColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.onSurfaceVariant.withValues(alpha: 0.42);
        }

        return baseColor;
      }),
      overlayColor: WidgetStatePropertyAll(baseColor.withValues(alpha: 0.08)),
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
            child: Transform.scale(
              scale: 1.04,
              child: _buildTabChip(context, tab),
            ),
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
}
