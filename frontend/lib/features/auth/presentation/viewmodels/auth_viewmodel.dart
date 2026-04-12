import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/features/auth/presentation/states/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void _clearErrorMessage() => _errorMessage = null;

  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _clearErrorMessage();

    _state = AuthState.loading;
    notifyListeners();

    try {
      await _authRepository.register(email: email, password: password);
      _state = AuthState.authenticated;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'Error al registrar. Por favor inténtelo de nuevo.';
    }

    notifyListeners();
  }
}
