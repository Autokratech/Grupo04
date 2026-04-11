import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/states/auth_state.dart';
import 'package:frontend/app/router/app_routes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthViewModel _viewModel = AuthViewModel();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_handleViewModelChanges);
  }

  void _handleViewModelChanges() {
    if (!mounted) return;

    if (_viewModel.state == AuthState.authenticated) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _submitLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    _viewModel.register(email, password);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelChanges);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  final isLoading = _viewModel.state == AuthState.loading;
                  final errorMessage = _viewModel.errorMessage;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Autokratech',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      TextField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!isLoading) {
                            _submitLogin();
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin,
                        child: const Text('Iniciar sesión'),
                      ),

                      if (isLoading) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Center(child: CircularProgressIndicator()),
                      ],

                      if (errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
