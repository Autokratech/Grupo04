import 'package:flutter/material.dart';
import 'package:frontend/app/di/service_locator.dart';
import 'package:frontend/app/router/app_routes.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/features/auth/presentation/states/auth_mode.dart';
import 'package:frontend/features/auth/presentation/states/auth_state.dart';
import 'package:frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const double _cardMaxWidth = 430;

  final AuthViewModel _viewModel = AuthViewModel(
    authRepository: sl<AuthRepository>(),
  );

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
  TextEditingController();

  AuthMode _authMode = AuthMode.login;

  bool get _isRegisterMode => _authMode == AuthMode.register;

  String get _screenTitle =>
      _authMode == AuthMode.register ? 'Crear cuenta' : 'Iniciar sesión';

  String get _screenSubtitle => _authMode == AuthMode.register
      ? 'Crea una cuenta para empezar a configurar tu dashboard.'
      : 'Accede a tu dashboard de monitorización.';

  String get _submitLabel =>
      _authMode == AuthMode.register ? 'Registrarse' : 'Entrar';

  String get _switchPrompt =>
      _isRegisterMode ? '¿Ya tienes cuenta?' : '¿No tienes cuenta?';

  String get _switchLabel => _isRegisterMode ? 'Inicia sesión' : 'Regístrate';

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_handleViewModelChanges);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanges);
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  final isLoading = _viewModel.state == AuthState.loading;
                  final errorMessage = _viewModel.errorMessage;

                  return _buildAuthCard(
                    context: context,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleViewModelChanges() {
    if (!mounted) return;

    if (_viewModel.state == AuthState.authenticated) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _authMode = _isRegisterMode ? AuthMode.login : AuthMode.register;
    });

    _passwordController.clear();
    _repeatPasswordController.clear();
    _viewModel.clearError();
  }

  void _submitAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isRegisterMode) {
      _viewModel.register(email: email, password: password);
    } else {
      _viewModel.login(email: email, password: password);
    }
  }

  Widget _buildAuthCard({
    required BuildContext context,
    required bool isLoading,
    required String? errorMessage,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 15,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthForm(
                    key: ValueKey(_authMode),
                    isRegisterMode: _isRegisterMode,
                    submitLabel: _submitLabel,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    repeatPasswordController: _repeatPasswordController,
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    onSubmit: _submitAuth,
                    onInputChanged: _viewModel.clearError,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildModeSwitch(context, isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.01),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.22),
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(
              Icons.dashboard_customize_outlined,
              color: colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autokratech',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _screenTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _screenSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSwitch(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            _switchPrompt,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12),
          TextButton(
            onPressed: isLoading ? null : _toggleAuthMode,
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _switchLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}