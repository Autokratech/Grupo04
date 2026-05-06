import 'package:shared_preferences/shared_preferences.dart';

class DashboardPreferencesService {
  static const String _selectedTabIdPrefix = 'selected_dashboard_tab_id_';

  final SharedPreferences sharedPreferences;

  DashboardPreferencesService({required this.sharedPreferences});

  String? getSelectedTabId({required String dashboardId}) {
    return sharedPreferences.getString(_keyForDashboard(dashboardId));
  }

  Future<void> saveSelectedTabId({
    required String dashboardId,
    required String tabId,
  }) {
    return sharedPreferences.setString(
      _keyForDashboard(dashboardId),
      tabId,
    );
  }

  Future<void> clearSelectedTabId({required String dashboardId}) {
    return sharedPreferences.remove(_keyForDashboard(dashboardId));
  }

  String _keyForDashboard(String dashboardId) {
    return '$_selectedTabIdPrefix$dashboardId';
  }
}