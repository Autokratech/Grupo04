import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:frontend/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';
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
    _viewModel.loadDashboard();
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
      return ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return DashboardCard(item: item);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      );
    }

    return const Center(child: Text('Estado de dashboard no soportado'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                const SizedBox(height: 24),
                Expanded(child: _buildDashboardContent()),
              ],
            );
          },
        ),
      ),
    );
  }
}
