import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/states/login_state.dart';

class LoginViewModel extends ChangeNotifier {
  LoginState _state = LoginState.initial;

  LoginState get state => _state;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void _clearErrorMessage() => _errorMessage = null;

  Future<void> login(String email, String password) async {
    _clearErrorMessage();

    _state = LoginState.loading;
    notifyListeners();

    try {
      final bool isAuthenticated = await _authenticateUser(email, password);

      if (isAuthenticated) {
        _state = LoginState.authenticated;
      } else {
        _state = LoginState.error;
        _errorMessage = 'Invalid email or password';
      }
    } catch (_) {
      _state = LoginState.error;
      _errorMessage = 'An error occurred during login';
    }

    notifyListeners();
  }

  void logout() {
    _state = LoginState.initial;
    _clearErrorMessage();
    notifyListeners();
  }

  Future<bool> _authenticateUser(String email, String password) async {
    if (email == 'admin@autokratech.com' && password == 'admin') {
      return true;
    }

    return false;
  }
}
