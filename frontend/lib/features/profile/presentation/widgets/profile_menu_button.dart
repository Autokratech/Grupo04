import 'package:flutter/material.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/domain/models/app_user.dart';
import 'package:frontend/domain/models/linked_provider_status.dart';
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
  static const double _menuWidth = 340;
  static const double _loadingHeight = 120;

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

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _openProfileDialog,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(
        Icons.account_circle_outlined,
        size: 25,
      ),
      label: Text(
        'Perfil',
        style: AppTextStyles.title
      ),
    );
  }

  Future<void> _openProfileDialog() async {
    if (_viewModel.state == ProfileState.initial) {
      _viewModel.loadCurrentUser();
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _menuWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      return _buildMenuContent(
                        context,
                        onClose: () => Navigator.of(dialogContext).pop(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final loggedOut = await _viewModel.logout();

    if (!loggedOut || !mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    widget.onLoggedOut();
  }

  Widget _buildMenuContent(
    BuildContext context, {
    required VoidCallback onClose,
  }) {
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

        return _buildLoadedContent(context, user, onClose: onClose);
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
        const SizedBox(height: AppSpacing.md),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildLoadedContent(
      BuildContext context,
      AppUser user, {
        required VoidCallback onClose,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccountInfo(context, user, onClose: onClose),
        const SizedBox(height: AppSpacing.lg),
        _buildProvidersSection(),
        const SizedBox(height: AppSpacing.lg),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildAccountInfo(
      BuildContext context,
      AppUser user, {
        required VoidCallback onClose,
      }) {
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
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 18),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
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
          description:
              'Conecta tu cuenta para mostrar repositorios, issues y pipelines.',
          status: LinkedProviderStatus.disconnected,
          actionLabel: 'Conectar',
        ),
        LinkedProviderTile(
          icon: Icons.account_tree_outlined,
          title: 'GitLab',
          description:
              'Conecta tu cuenta para mostrar proyectos, merge requests y pipelines.',
          status: LinkedProviderStatus.disconnected,
          actionLabel: 'Conectar',
        ),
        LinkedProviderTile(
          icon: Icons.memory_outlined,
          title: 'Agentes',
          description:
              'Registra un agente para recibir métricas de sistema e infraestructura.',
          status: LinkedProviderStatus.unavailable,
          actionLabel: 'Gestionar',
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
