import 'package:frontend/data/services/local/datasources/dashboard_local_data_source.dart';
import 'package:frontend/data/services/local/datasources/web_dashboard_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

DashboardLocalDataSource createPlatformDashboardLocalDataSource({
  required SharedPreferences sharedPreferences,
}) {
  return WebDashboardLocalDataSource(sharedPreferences: sharedPreferences);
}
