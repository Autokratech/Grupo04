import 'package:flutter/foundation.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/repositories/profile_repository/profile_repository.dart';
import 'package:frontend/domain/models/app_user.dart';
import 'package:frontend/features/profile/presentation/states/profile_state.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;

  ProfileState _state = ProfileState.initial;
  AppUser? _currentUser;
  String? _errorMessage;
  bool _isLoggingOut = false;

  ProfileViewModel({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository;

  ProfileState get state => _state;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoggingOut => _isLoggingOut;

  Future<void> loadCurrentUser() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _profileRepository.getCurrentUser();
      _state = ProfileState.loaded;
    } catch (_) {
      _state = ProfileState.error;
      _errorMessage = 'No se ha podido cargar el perfil.';
    }

    notifyListeners();
  }

  Future<bool> logout() async {
    _isLoggingOut = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.logout();
      return true;
    } catch (_) {
      _errorMessage = 'No se ha podido cerrar sesión.';
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }
}
