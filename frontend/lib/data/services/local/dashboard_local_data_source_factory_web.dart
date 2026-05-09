import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/data/services/local/web_dashboard_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

DashboardLocalDataSource createPlatformDashboardLocalDataSource({
  required SharedPreferences sharedPreferences,
}) {
  return WebDashboardLocalDataSource(sharedPreferences: sharedPreferences);
}
