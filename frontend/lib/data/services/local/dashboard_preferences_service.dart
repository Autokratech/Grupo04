import 'package:shared_preferences/shared_preferences.dart';

class DashboardPreferencesService {
  static const String _selectedPresetIdKey = 'selected_dashboard_preset_id';

  final SharedPreferences sharedPreferences;

  DashboardPreferencesService({required this.sharedPreferences});

  String? get selectedPresetId {
    return sharedPreferences.getString(_selectedPresetIdKey);
  }

  Future<void> saveSelectedPresetId(String presetId) {
    return sharedPreferences.setString(_selectedPresetIdKey, presetId);
  }

  Future<void> clearSelectedPresetId() {
    return sharedPreferences.remove(_selectedPresetIdKey);
  }
}
