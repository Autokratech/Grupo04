import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_spacing.dart';

class AuthForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController repeatPasswordController;

  final bool isLoading;
  final String? errorMessage;
  final bool isRegisterMode;
  final String submitLabel;
  final VoidCallback onSubmit;
  final VoidCallback? onInputChanged;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.repeatPasswordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.isRegisterMode,
    required this.submitLabel,
    this.onInputChanged,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (_) => widget.onInputChanged?.call(),
            validator: (value) {
              final email = value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Introduce un email';
              }

              if (!_emailRegex.hasMatch(email)) {
                return 'Introduce un email válido';
              }

              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          TextFormField(
            controller: widget.passwordController,
            textInputAction: widget.isRegisterMode
                ? TextInputAction.next
                : TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Contraseña'),
            obscureText: true,
            onChanged: (_) => widget.onInputChanged?.call(),
            onFieldSubmitted: (_) {
              if (!widget.isRegisterMode) _handleSubmit();
            },
            validator: (value) {
              final password = value?.trim() ?? '';

              if (password.isEmpty) {
                return 'Introduce una contraseña';
              }

              return null;
            },
          ),

          if (widget.isRegisterMode) ...[
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: widget.repeatPasswordController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Repetir contraseña',
              ),
              obscureText: true,
              onChanged: (_) => widget.onInputChanged?.call(),
              onFieldSubmitted: (_) => _handleSubmit(),
              validator: (value) {
                final password = widget.passwordController.text.trim();
                final repeatPassword = value?.trim() ?? '';

                if (repeatPassword.isEmpty) {
                  return 'Debes repetir la contraseña';
                }

                if (repeatPassword != password) {
                  return 'Las contraseñas no coinciden';
                }

                return null;
              },
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),

          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            child: Text(widget.submitLabel),
          ),

          if (widget.isLoading) ...[
            const SizedBox(height: AppSpacing.md),
            const Center(child: CircularProgressIndicator()),
          ],

          if (widget.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
