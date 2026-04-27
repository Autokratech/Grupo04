import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/router/app_routes.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:frontend/features/dashboard/presentation/widgets/details_side_panel.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_tab_selector.dart';
import 'package:frontend/features/dashboard/presentation/widgets/widget_grid.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthRepository _authRepository = sl<AuthRepository>();
  final DashboardViewModel _viewModel = DashboardViewModel(
    dashboardRepository: sl<DashboardRepository>(),
    dashboardPreferencesService: sl<DashboardPreferencesService>(),
  );
  final Object _dashboardDetailTapGroup = Object();

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

  Future<void> _handleLogout() async {
    try {
      await _authRepository.logout();

      if (!mounted) return;

      context.go(AppRoutes.auth);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al cerrar sesión')));
    }
  }

  Widget _buildDashboardContent(
    DashboardState state,
    List<DashboardWidgetItem> items,
    DashboardWidgetItem? selectedItem,
    String? errorMessage,
  ) {
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
      return const Center(child: Text('No hay widgets disponibles'));
    }

    if (state == DashboardState.loaded) {
      return WidgetGrid(
        items: items,
        selectedItem: selectedItem,
        onItemSelected: _viewModel.selectItem,
      );
    }

    return const Center(child: Text('Estado de dashboard no soportado'));
  }

  Widget _buildTapProtectedArea({required Widget child}) {
    return TapRegion(
      groupId: _dashboardDetailTapGroup,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
        _viewModel.clearSelectedItem();
      },
      child: child,
    );
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    title: 'Dashboard',
                    subtitle: 'Vista general de monitorización',
                    onLogoutPressed: _handleLogout,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (selectedTab != null) ...[
                    DashboardTabSelector(
                      tabs: tabs,
                      selectedTab: selectedTab,
                      canCreateTab: _viewModel.canCreateTab,
                      onTabChanged: _viewModel.changeTab,
                      onCreateTabPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Aquí abriremos el diálogo para crear un pestaña',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWideLayout = constraints.maxWidth >= 900;
                        final mainContent = _buildTapProtectedArea(
                          child: _buildDashboardContent(
                            state,
                            items,
                            selectedItem,
                            errorMessage,
                          ),
                        );

                        if (!isWideLayout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: mainContent),
                              if (selectedItem != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                _buildTapProtectedArea(
                                  child: DetailsSidePanel(item: selectedItem),
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
                                width: 320,
                                child: _buildTapProtectedArea(
                                  child: DetailsSidePanel(item: selectedItem),
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
}
