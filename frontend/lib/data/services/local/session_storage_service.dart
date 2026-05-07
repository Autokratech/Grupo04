import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  static const String _accessToken = 'access_token';
  static const String _tokenType = 'token_type';

  final SharedPreferences _sharedPreferences;

  String? get accessToken => _sharedPreferences.getString(_accessToken);
  String? get tokenType => _sharedPreferences.getString(_tokenType);
  bool get hasSession => accessToken != null && tokenType != null;

  SessionStorageService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  Future<void> saveSession({
    required String accessToken,
    required String tokenType,
  }) async {
    await _sharedPreferences.setString(_accessToken, accessToken);
    await _sharedPreferences.setString(_tokenType, tokenType);
  }

  Future<void> clearSession() async {
    await _sharedPreferences.remove(_accessToken);
    await _sharedPreferences.remove(_tokenType);
  }
}
