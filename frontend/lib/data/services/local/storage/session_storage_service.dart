import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  static const String _accessToken = 'access_token';
  static const String _tokenType = 'token_type';
  static const String _userId = 'user_id';

  final SharedPreferences _sharedPreferences;

  String? get accessToken => _sharedPreferences.getString(_accessToken);
  String? get tokenType => _sharedPreferences.getString(_tokenType);
  String? get userId => _sharedPreferences.getString(_userId);

  bool get hasSession => accessToken != null && tokenType != null;

  SessionStorageService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  Future<void> saveSession({
    required String accessToken,
    required String tokenType,
    required String userId,
  }) async {
    await _sharedPreferences.setString(_accessToken, accessToken);
    await _sharedPreferences.setString(_tokenType, tokenType);
    await _sharedPreferences.setString(_userId, userId);
  }

  Future<void> clearSession() async {
    await _sharedPreferences.remove(_accessToken);
    await _sharedPreferences.remove(_tokenType);
    await _sharedPreferences.remove(_userId);
  }
}
