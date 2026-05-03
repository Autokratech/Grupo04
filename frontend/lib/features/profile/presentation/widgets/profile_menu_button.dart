import 'package:flutter/material.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/domain/models/app_user.dart';
import 'package:frontend/domain/models/user_role.dart';
import 'package:frontend/features/profile/presentation/states/profile_state.dart';
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:frontend/features/profile/presentation/widgets/linked_provider_tile.dart';

class ProfileMenuButton extends StatefulWidget {
  final VoidCallback onLoggedOut;

  const ProfileMenuButton({super.key, required this.onLoggedOut});

  @override
  State<ProfileMenuButton> createState() => _ProfileMenuButtonState();
}

class _ProfileMenuButtonState extends State<ProfileMenuButton> {
  static const double _menuWidth = 300;
  static const double _loadingHeight = 120;
  static const Offset _menuOffset = Offset(-200, 8);

  final MenuController _menuController = MenuController();
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProfileViewModel>();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_menuController.isOpen) {
      _menuController.close();
      return;
    }

    _menuController.open();

    if (_viewModel.state == ProfileState.initial) {
      _viewModel.loadCurrentUser();
    }
  }

  Future<void> _logout() async {
    final loggedOut = await _viewModel.logout();

    if (!loggedOut || !mounted) return;

    _menuController.close();
    widget.onLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: _menuOffset,
      reservedPadding: const EdgeInsets.all(AppSpacing.lg),
      style: MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      menuChildren: [
        SizedBox(
          width: _menuWidth,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return _buildMenuContent(context);
              },
            ),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return TextButton.icon(
          onPressed: _toggleMenu,
          icon: const Icon(Icons.account_circle_outlined),
          label: const Text('Perfil'),
        );
      },
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    switch (_viewModel.state) {
      case ProfileState.initial:
      case ProfileState.loading:
        return _buildLoadingContent();

      case ProfileState.error:
        return _buildErrorContent(context);

      case ProfileState.loaded:
        final user = _viewModel.currentUser;

        if (user == null) {
          return _buildErrorContent(context);
        }

        return _buildLoadedContent(context, user);
    }
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: _loadingHeight,
          child: Center(child: CircularProgressIndicator()),
        ),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildLoadedContent(BuildContext context, AppUser user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccountInfo(context, user),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        _buildProvidersSection(),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context, AppUser user) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.account_circle_outlined, size: 32),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.email,
                style: textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _roleLabel(user.role),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (!user.active) ...[
                const SizedBox(height: 4),
                Text(
                  'Cuenta inactiva',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conexiones'),
        SizedBox(height: AppSpacing.sm),
        LinkedProviderTile(
          icon: Icons.code,
          title: 'GitHub',
          statusLabel: 'Preparado para futura vinculación OAuth.',
          connected: false,
        ),
        LinkedProviderTile(
          icon: Icons.account_tree_outlined,
          title: 'GitLab',
          statusLabel: 'Preparado para futura vinculación OAuth.',
          connected: false,
        ),
        LinkedProviderTile(
          icon: Icons.cloud_outlined,
          title: 'Cloud providers',
          statusLabel: 'Pendiente de contrato backend.',
          connected: false,
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _viewModel.isLoggingOut ? null : _logout,
        icon: _viewModel.isLoggingOut
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(_viewModel.isLoggingOut ? 'Cerrando...' : 'Cerrar sesión'),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _viewModel.errorMessage ?? 'No se ha podido cargar el perfil.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.error),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: _viewModel.loadCurrentUser,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
        const SizedBox(height: AppSpacing.md),
        const Divider(height: 1),
        const SizedBox(height: AppSpacing.md),
        _buildLogoutButton(),
      ],
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Superadmin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.user:
        return 'Usuario';
      case UserRole.guest:
        return 'Invitado';
    }
  }
}
