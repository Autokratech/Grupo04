import 'package:flutter/material.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/utils/app_platform.dart';
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
  static const double _dialogMaxWidth = 520;
  static const double _loadingHeight = 140;

  late final ProfileViewModel _viewModel;

  final ScrollController _profileScrollController = ScrollController(
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ProfileViewModel>();
  }

  @override
  void dispose() {
    _profileScrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppPlatform.isMobile;

    return TextButton.icon(
      onPressed: _openProfileDialog,
      icon: Icon(
        Icons.account_circle_outlined,
        size: isMobile ? 20 : 30,
        color: colorScheme.primary,
      ),
      label: Text(
        'Perfil',
        style: TextStyle(
          fontSize: isMobile ? 13 : 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 18,
          vertical: isMobile ? 9 : 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.55),
          width: 1.2,
        ),
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return Dialog(
              insetPadding: const EdgeInsets.all(AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _dialogMaxWidth,
                  maxHeight: constraints.maxHeight * 0.85,
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg + 32,
                        AppSpacing.sm,
                        AppSpacing.lg,
                      ),
                      child: ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) {
                          return _buildDialogContent(context);
                        },
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close, size: 18),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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

  Future<void> _connectGithub() async {
    await _viewModel.connectGithub();

    if (!mounted) return;

    final errorMessage = _viewModel.errorMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage ?? 'Se ha abierto GitHub para autorizar la conexión.',
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
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
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: _buildAccountInfo(context, user),
        ),
        const SizedBox(height: AppSpacing.md),
        Flexible(child: _buildScrollableProvidersSection(context)),
      ],
    );
  }

  Widget _buildScrollableProvidersSection(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        controller: _profileScrollController,
        thumbVisibility: false,
        radius: const Radius.circular(999),
        thickness: 4,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: SingleChildScrollView(
            controller: _profileScrollController,
            child: _buildProvidersSection(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, AppUser user) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 36,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _roleLabel(user.role),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
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
          _buildCompactLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProvidersSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Conexiones', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Vinculaciones preparadas para futuros widgets. OAuth real pendiente de contrato backend.',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          LinkedProviderTile(
            icon: Icons.code,
            title: 'GitHub',
            description:
            'Conecta tu cuenta para mostrar repositorios, issues y pipelines.',
            status: LinkedProviderStatus.disconnected,
            actionLabel: 'Conectar',
            onAction: _connectGithub,
          ),
          const SizedBox(height: AppSpacing.sm),
          const LinkedProviderTile(
            icon: Icons.account_tree_outlined,
            title: 'GitLab',
            description:
                'Conecta tu cuenta para mostrar proyectos, merge requests y pipelines.',
            status: LinkedProviderStatus.disconnected,
            actionLabel: 'Conectar',
          ),
          const SizedBox(height: AppSpacing.sm),
          const LinkedProviderTile(
            icon: Icons.memory_outlined,
            title: 'Agentes',
            description:
                'Registra un agente para recibir métricas de sistema e infraestructura.',
            status: LinkedProviderStatus.unavailable,
            actionLabel: 'Gestionar',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLogoutButton() {
    return FilledButton.tonalIcon(
      onPressed: _viewModel.isLoggingOut ? null : _logout,
      icon: _viewModel.isLoggingOut
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout, size: 18),
      label: Text(_viewModel.isLoggingOut ? 'Cerrando...' : 'Cerrar sesión'),
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: _viewModel.isLoggingOut ? null : _logout,
        icon: _viewModel.isLoggingOut
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(_viewModel.isLoggingOut ? 'Cerrando...' : 'Cerrar sesión'),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
    return switch (role) {
      UserRole.superadmin => 'Superadmin',
      UserRole.admin => 'Admin',
      UserRole.user => 'Usuario',
      UserRole.guest => 'Invitado',
    };
  }
}
