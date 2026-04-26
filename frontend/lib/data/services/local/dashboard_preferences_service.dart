import 'package:shared_preferences/shared_preferences.dart';

class DashboardPreferencesService {
  static const String _selectedTabIdKey = 'selected_dashboard_preset_id';

  final SharedPreferences sharedPreferences;

  DashboardPreferencesService({required this.sharedPreferences});

  String? get selectedTabId {
    return sharedPreferences.getString(_selectedTabIdKey);
  }

  Future<void> saveSelectedTabId(String presetId) {
    return sharedPreferences.setString(_selectedTabIdKey, presetId);
  }

  Future<void> clearSelectedTabId() {
    return sharedPreferences.remove(_selectedTabIdKey);
  }
}
