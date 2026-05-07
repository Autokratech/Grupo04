import 'package:flutter/material.dart';
import 'package:frontend/domain/models/widget_catalog_item.dart';
import 'package:frontend/features/dashboard/presentation/widgets/add_widget_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/app/router/app_routes.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:frontend/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:frontend/features/dashboard/presentation/widgets/create_dashboard_tab_dialog.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_tab_selector.dart';
import 'package:frontend/features/dashboard/presentation/widgets/delete_dashboard_tab_dialog.dart';
import 'package:frontend/features/dashboard/presentation/widgets/details_side_panel.dart';
import 'package:frontend/features/dashboard/presentation/widgets/widget_grid.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_menu_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const double _wideLayoutBreakpoint = 900;
  static const double _detailsPanelWidth = 320;
  static const double _portraitBottomSheetHeightFactor = 0.60;
  static const double _landscapeBottomSheetHeightFactor = 0.90;

  final DashboardViewModel _viewModel = DashboardViewModel(
    dashboardRepository: sl<DashboardRepository>(),
    dashboardPreferencesService: sl<DashboardPreferencesService>(),
  );

  bool get _isMobilePlatform => AppPlatform.isMobile;

  @override
  void initState() {
    super.initState();
    _viewModel.initializeDashboard();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final state = _viewModel.state;
              final items = _viewModel.items;
              final errorMessage = _viewModel.errorMessage;
              final tabs = _viewModel.tabs;
              final selectedTab = _viewModel.selectedTab;
              final selectedItem = _viewModel.selectedItem;

              final isMobileLandscape =
                  AppPlatform.isMobile &&
                  MediaQuery.of(context).orientation == Orientation.landscape;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMobileLandscape) ...[
                    if (selectedTab != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildTabSelector(
                              tabs: tabs,
                              selectedTab: selectedTab,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          ProfileMenuButton(
                            onLoggedOut: _handleProfileLoggedOut,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ] else ...[
                    DashboardHeader(
                      title: 'Dashboard',
                      subtitle: 'Vista general de monitorización',
                      trailing: ProfileMenuButton(
                        onLoggedOut: _handleProfileLoggedOut,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (selectedTab != null) ...[
                      _buildTabSelector(tabs: tabs, selectedTab: selectedTab),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideLayout =
                            constraints.maxWidth >= _wideLayoutBreakpoint;

                        final mainContent = _buildDashboardContent(
                          state,
                          items,
                          selectedItem,
                          errorMessage,
                          hasSelectedTab: selectedTab != null,
                          canAddWidget: _viewModel.canAddWidget,
                          onAddWidgetPressed: _handleAddWidgetPressed,
                          onItemSelected: (item) {
                            if (_isMobilePlatform) {
                              _showDetailsBottomSheet(item);
                              return;
                            }

                            _handleDesktopItemSelected(item);
                          },
                        );

                        if (!isWideLayout) {
                          if (_isMobilePlatform) {
                            return mainContent;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: mainContent),

                              if (selectedItem != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight * 0.40,
                                  ),
                                  child: DetailsSidePanel(
                                    item: selectedItem,
                                    placement: DetailsPanelPlacement.bottom,
                                    onClose: _viewModel.clearSelectedItem,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: mainContent),
                            if (selectedItem != null) ...[
                              const SizedBox(width: AppSpacing.lg),
                              SizedBox(
                                width: _detailsPanelWidth,
                                child: DetailsSidePanel(
                                  item: selectedItem,
                                  placement: DetailsPanelPlacement.side,
                                  onClose: _viewModel.clearSelectedItem,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleProfileLoggedOut() {
    if (!mounted) return;

    context.go(AppRoutes.auth);
  }

  Future<void> _handleAddWidgetPressed() async {
    final selectedCatalogItem = await showDialog<WidgetCatalogItem>(
      context: context,
      builder: (_) =>
          AddWidgetDialog(items: _viewModel.availableWidgetCatalogItems),
    );

    if (selectedCatalogItem == null || !mounted) return;

    await _viewModel.addWidget(selectedCatalogItem);

    _showViewModelErrorIfNeeded();
  }

  Widget _buildDashboardContent(
    DashboardState state,
    List<DashboardWidgetItem> items,
    DashboardWidgetItem? selectedItem,
    String? errorMessage, {
    required bool hasSelectedTab,
    required bool canAddWidget,
    required VoidCallback onAddWidgetPressed,
    required ValueChanged<DashboardWidgetItem> onItemSelected,
  }) {
    if (state == DashboardState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state == DashboardState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ha ocurrido un error al cargar el dashboard'),

            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _viewModel.initializeDashboard,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state == DashboardState.empty) {
      if (hasSelectedTab && canAddWidget) {
        return WidgetGrid(
          items: items,
          selectedItem: selectedItem,
          onItemSelected: onItemSelected,
          onItemsReordered: _viewModel.reorderWidgets,
          canAddWidget: canAddWidget,
          onAddWidgetPressed: onAddWidgetPressed,
        );
      }

      return const Center(child: Text('No hay widgets disponibles'));
    }

    if (state == DashboardState.loaded) {
      return WidgetGrid(
        items: items,
        selectedItem: selectedItem,
        onItemSelected: onItemSelected,
        onItemsReordered: _viewModel.reorderWidgets,
        canAddWidget: canAddWidget,
        onAddWidgetPressed: onAddWidgetPressed,
      );
    }

    return const Center(child: Text('Estado de dashboard no soportado'));
  }

  Future<void> _handleCreateTabPressed() async {
    final tabName = await showDialog<String>(
      context: context,
      builder: (_) => const CreateDashboardTabDialog(),
    );

    if (tabName == null || !mounted) return;

    await _viewModel.createTab(tabName);

    _showViewModelErrorIfNeeded();
  }

  Future<void> _handleRenameTabPressed(DashboardTab tab) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => CreateDashboardTabDialog(
        title: 'Renombrar dashboard',
        initialName: tab.name,
        submitLabel: 'Guardar',
      ),
    );

    if (newName == null || !mounted) return;

    await _viewModel.renameTab(tab: tab, name: newName);

    _showViewModelErrorIfNeeded();
  }

  Future<void> _handleDeleteTabPressed(DashboardTab tab) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDashboardTabDialog(dashboardName: tab.name),
    );

    if (shouldDelete != true || !mounted) return;

    await _viewModel.deleteTab(tab);

    _showViewModelErrorIfNeeded();
  }

  Future<void> _handleTabsReordered(List<DashboardTab> reorderedTabs) async {
    await _viewModel.reorderTabs(reorderedTabs);

    _showViewModelErrorIfNeeded();
  }

  Future<void> _showDetailsBottomSheet(DashboardWidgetItem item) async {
    _viewModel.selectItem(item);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final isLandscape = mediaQuery.orientation == Orientation.landscape;

        return FractionallySizedBox(
          heightFactor: isLandscape
              ? _landscapeBottomSheetHeightFactor
              : _portraitBottomSheetHeightFactor,
          child: SafeArea(
            top: false,
            child: DetailsSidePanel(item: item, showCard: false),
          ),
        );
      },
    );

    if (!mounted) return;

    if (_viewModel.selectedItem?.id == item.id) {
      _viewModel.clearSelectedItem();
    }
  }

  void _handleDesktopItemSelected(DashboardWidgetItem item) {
    if (_viewModel.selectedItem?.id == item.id) {
      _viewModel.clearSelectedItem();
      return;
    }

    _viewModel.selectItem(item);
  }

  Widget _buildTabSelector({
    required List<DashboardTab> tabs,
    required DashboardTab selectedTab,
  }) {
    return DashboardTabSelector(
      tabs: tabs,
      selectedTab: selectedTab,
      canCreateTab: _viewModel.canCreateTab,
      canDeleteTab: tabs.length > 1,
      onTabChanged: _viewModel.changeTab,
      onCreateTabPressed: _handleCreateTabPressed,
      onRenameTabPressed: _handleRenameTabPressed,
      onDeleteTabPressed: _handleDeleteTabPressed,
      onTabsReordered: _handleTabsReordered,
    );
  }

  void _showViewModelErrorIfNeeded() {
    final errorMessage = _viewModel.errorMessage;

    if (errorMessage == null || !mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}
