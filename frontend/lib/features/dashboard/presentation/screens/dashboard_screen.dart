import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/dashboard_widget_item.dart';
import 'package:frontend/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:frontend/features/dashboard/presentation/widgets/details_side_panel.dart';
import 'package:frontend/features/dashboard/presentation/widgets/preset_selector.dart';
import 'package:frontend/features/dashboard/presentation/widgets/widget_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/app/router/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardViewModel _viewModel = DashboardViewModel();

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

  void _handleLogout() {
    context.go(AppRoutes.login);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
          _viewModel.clearSelectedItem();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final state = _viewModel.state;
                final items = _viewModel.items;
                final errorMessage = _viewModel.errorMessage;
                final presets = _viewModel.presets;
                final selectedPreset = _viewModel.selectedPreset;
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
                    if (selectedPreset != null) ...[
                      PresetSelector(
                        presets: presets,
                        selectedPreset: selectedPreset,
                        onPresetChanged: _viewModel.changePreset,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _buildDashboardContent(
                              state,
                              items,
                              selectedItem,
                              errorMessage,
                            ),
                          ),
                          if (selectedItem != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            DetailsSidePanel(item: selectedItem),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
