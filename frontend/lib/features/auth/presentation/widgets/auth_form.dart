import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
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

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

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
          _buildEmailField(),
          const SizedBox(height: AppSpacing.md),
          _buildPasswordField(),
          if (widget.isRegisterMode) ...[
            const SizedBox(height: AppSpacing.md),
            _buildRepeatPasswordField(),
          ],
          const SizedBox(height: AppSpacing.xl),
          _buildSubmitButton(),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildErrorMessage(context),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !widget.isLoading,
      decoration: _inputDecoration(
        label: 'Email',
        icon: Icons.mail_outline_rounded,
      ),
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
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      textInputAction: widget.isRegisterMode
          ? TextInputAction.next
          : TextInputAction.done,
      enabled: !widget.isLoading,
      decoration: _inputDecoration(
        label: 'Contraseña',
        icon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
        ),
      ),
      obscureText: _obscurePassword,
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
    );
  }

  Widget _buildRepeatPasswordField() {
    return TextFormField(
      controller: widget.repeatPasswordController,
      textInputAction: TextInputAction.done,
      enabled: !widget.isLoading,
      decoration: _inputDecoration(
        label: 'Repetir contraseña',
        icon: Icons.lock_reset_rounded,
        suffixIcon: IconButton(
          onPressed: widget.isLoading
              ? null
              : () {
                  setState(() {
                    _obscureRepeatPassword = !_obscureRepeatPassword;
                  });
                },
          icon: Icon(
            _obscureRepeatPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
        ),
      ),
      obscureText: _obscureRepeatPassword,
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
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.primary.withValues(alpha: 0.025),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.70),
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: widget.isLoading ? null : _handleSubmit,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.submitLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colorScheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
