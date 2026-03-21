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
  final LoginViewModel _vm = LoginViewModel();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.addListener(_handleViewModelChanges);
  }

  void _handleViewModelChanges() {
    if (!mounted) return;

    if (_vm.state == LoginState.authenticated) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _submitLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    _vm.login(email, password);
  }

  @override
  void dispose() {
    _vm.removeListener(_handleViewModelChanges);
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
                listenable: _vm,
                builder: (context, child) {
                  final isLoading = _vm.state == LoginState.loading;
                  final errorMessage = _vm.errorMessage;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 24),

                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 12),

                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin,
                        child: Text('Iniciar sesión'),
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
