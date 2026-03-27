import 'package:flutter/material.dart';
import 'package:frontend/domain/models/dashboard_preset.dart';
import 'package:frontend/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';
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

  final List<DashboardPreset> _presets = const [
    DashboardPreset(id: 'default', name: 'Por defecto'),
    DashboardPreset(id: 'operations', name: 'Operaciones'),
    DashboardPreset(id: 'pc_resources', name: 'Recursos PC'),
  ];

  late DashboardPreset _selectedPreset;

  @override
  void initState() {
    super.initState();
    _selectedPreset = _presets.first;
    _viewModel.loadDashboard();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleLogout() {
    context.go(AppRoutes.login);
  }

  Widget _buildDashboardContent() {
    final state = _viewModel.state;
    final items = _viewModel.items;
    final errorMessage = _viewModel.errorMessage;

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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _viewModel.loadDashboard,
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
      return WidgetGrid(items: items);
    }

    return const Center(child: Text('Estado de dashboard no soportado'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    title: 'Dashboard',
                    subtitle: 'Vista general de monitorización',
                    onLogoutPressed: _handleLogout,
                  ),
                  const SizedBox(height: 16),
                  PresetSelector(
                    presets: _presets,
                    selectedPreset: _selectedPreset,
                    onPresetChanged: (preset) {
                      setState(() {
                        _selectedPreset = preset;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _buildDashboardContent()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
