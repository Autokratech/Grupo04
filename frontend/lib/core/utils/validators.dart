class Validators {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Introduce un email';
    }

    if (!_emailRegex.hasMatch(email)) {
      return 'Introduce un email válido';
    }

    return null;
  }

  static String? password(String? value) {
    final password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Introduce una contraseña';
    }

    return null;
  }

  static String? repeatPassword(String? value, {required String password}) {
    final cleanPassword = password.trim();
    final repeatPassword = value?.trim() ?? '';

    if (repeatPassword.isEmpty) {
      return 'Debes repetir la contraseña';
    }

    if (repeatPassword != cleanPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }
}
