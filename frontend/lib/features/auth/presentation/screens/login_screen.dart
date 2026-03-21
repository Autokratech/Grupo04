import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/presentation/states/login_state.dart';
import 'package:frontend/app/router/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel _viewModel = LoginViewModel();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_handleViewModelChanges);
  }

  void _handleViewModelChanges() {
    if (!mounted) return;

    if (_viewModel.state == LoginState.authenticated) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _submitLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    _viewModel.login(email, password);
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
              padding: const EdgeInsets.all(24),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  final isLoading = _viewModel.state == LoginState.loading;
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
                      const SizedBox(height: 24),

                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin,
                        child: const Text('Iniciar sesión'),
                      ),

                      if (isLoading) ...[
                        const SizedBox(height: 12),
                        const Center(child: CircularProgressIndicator()),
                      ],

                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
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
