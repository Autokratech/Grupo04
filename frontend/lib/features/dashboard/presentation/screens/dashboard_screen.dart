import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/features/dashboard/presentation/models/add_widget_dialog_result.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dialogs/add_widget_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/app/router/app_routes.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/storage/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard_tab.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:frontend/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dialogs/create_dashboard_tab_dialog.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_tab_selector.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dialogs/delete_dashboard_tab_dialog.dart';
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

  static const double _footerHeight = 34;
  static const double _footerShadowHeight = 22;

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

            final showFooter = !AppPlatform.isMobile;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderSurface(
                  child: isMobileLandscape
                      ? Row(
                          children: [
                            if (selectedTab != null)
                              Expanded(
                                child: _buildTabSelector(
                                  tabs: tabs,
                                  selectedTab: selectedTab,
                                ),
                              )
                            else
                              const Spacer(),
                            const SizedBox(width: AppSpacing.md),
                            ProfileMenuButton(
                              onLoggedOut: _handleProfileLoggedOut,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DashboardHeader(
                              title: 'Autokratech',
                              subtitle: _isMobilePlatform
                                  ? null
                                  : 'Centraliza métricas, alertas y conexiones en dashboards configurables.',
                              leading: SizedBox(
                                width: _isMobilePlatform ? 34 : 50,
                                height: _isMobilePlatform ? 34 : 50,
                                child: SvgPicture.asset(
                                  'assets/icons/logo/a.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              trailing: ProfileMenuButton(
                                onLoggedOut: _handleProfileLoggedOut,
                              ),
                            ),
                            if (selectedTab != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _buildTabSelector(
                                tabs: tabs,
                                selectedTab: selectedTab,
                              ),
                            ],
                          ],
                        ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
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
                                        onDelete: () {
                                          _handleDeleteWidgetPressed(
                                            selectedItem,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }

                            final sidePanelTopOffset = AppSpacing.xs;
                            final sidePanelBottomReservedSpace =
                                _footerHeight + AppSpacing.sm;
                            final sidePanelHeight =
                                constraints.maxHeight -
                                sidePanelTopOffset -
                                sidePanelBottomReservedSpace;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: mainContent),
                                if (selectedItem != null) ...[
                                  const SizedBox(width: AppSpacing.lg),
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.md,
                                      ),
                                      child: SizedBox(
                                        width: _detailsPanelWidth,
                                        height: sidePanelHeight,
                                        child: DetailsSidePanel(
                                          item: selectedItem,
                                          placement: DetailsPanelPlacement.side,
                                          onClose: _viewModel.clearSelectedItem,
                                          onDelete: () {
                                            _handleDeleteWidgetPressed(
                                              selectedItem,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildHeaderShadowOverlay(),
                      ),

                      if (showFooter) ...[
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: _footerHeight,
                          child: _buildFooterShadowOverlay(),
                        ),

                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _buildFooterBar(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleProfileLoggedOut() {
    if (!mounted) return;

    context.go(AppRoutes.auth);
  }

  Future<void> _handleAddWidgetPressed() async {
    final result = await showDialog<AddWidgetDialogResult>(
      context: context,
      builder: (_) =>
          AddWidgetDialog(items: _viewModel.availableWidgetCatalogItems),
    );

    if (result == null || !mounted) return;

    await _viewModel.addWidget(
      catalogItem: result.item,
      option: result.option,
    );

    if (!mounted) return;

    _showViewModelErrorIfNeeded();
  }

  Future<void> _handleDeleteWidgetPressed(DashboardWidgetItem widget) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Quitar widget'),
          content: Text('¿Quieres quitar "${widget.title}" de este dashboard?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Quitar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    await _viewModel.deleteWidget(widget);

    if (!mounted) return;

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

  Widget _buildHeaderSurface({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    final startColor = Color.alphaBlend(
      AppColors.secondary.withValues(alpha: 0.12),
      colorScheme.surface.withValues(alpha: 0.4),
    );

    final endColor = Color.alphaBlend(
      AppColors.secondary.withValues(alpha: 0.03),
      colorScheme.surface.withValues(alpha: 0.4),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppPlatform.isMobile &&
                      MediaQuery.of(context).orientation == Orientation.portrait
                  ? AppSpacing.sm
                  : AppSpacing.lg,
              AppSpacing.md,
            ),
            child: child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 2,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShadowOverlay() {
    return IgnorePointer(
      child: Container(
        height: 18,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.40, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final year = DateTime.now().year;

    return Container(
      height: _footerHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            width: 2,
            color: AppColors.primary.withValues(alpha: 0.151),
          ),
        ),
      ),
      child: Text(
        '© $year Autokratech. Todos los derechos reservados.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooterShadowOverlay() {
    return IgnorePointer(
      child: Container(
        height: _footerShadowHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.15),
              Colors.transparent,
            ],
            stops: const [0.0, 0.40, 1.0],
          ),
        ),
      ),
    );
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
            child: DetailsSidePanel(
              item: item,
              showCard: false,
              onDelete: () async {
                await _handleDeleteWidgetPressed(item);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
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
