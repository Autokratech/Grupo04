import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/features/auth/presentation/states/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  Future<void> _runAuthAction(
    Future<Object?> Function() action, {
    required String errorMessage,
  }) async {
    if (_state == AuthState.loading) return;

    _resetErrorState();
    _state = AuthState.loading;
    notifyListeners();

    try {
      await action();
      _state = AuthState.authenticated;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = errorMessage;
    }

    notifyListeners();
  }

  Future<void> register({required String email, required String password}) {
    return _runAuthAction(
      () => _authRepository.register(email: email, password: password),
      errorMessage: 'Error al registrar. Por favor inténtelo de nuevo.',
    );
  }

  Future<void> login({required String email, required String password}) {
    return _runAuthAction(
      () => _authRepository.login(email: email, password: password),
      errorMessage: 'Error al iniciar sesión. Por favor inténtelo de nuevo.',
    );
  }

  void _resetErrorState() {
    _errorMessage = null;

    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
  }

  void clearError() {
    if (_errorMessage == null && _state != AuthState.error) return;

    _resetErrorState();
    notifyListeners();
  }
}
