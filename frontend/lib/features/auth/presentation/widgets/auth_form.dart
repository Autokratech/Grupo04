import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: passwordController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLoading) {
              onSubmit();
            }
          },
          decoration: const InputDecoration(labelText: 'Contraseña'),
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.xxl),

        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          child: const Text('Registrarse'),
        ),

        if (isLoading) ...[
          const SizedBox(height: AppSpacing.md),
          const Center(child: CircularProgressIndicator()),
        ],

        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            errorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
