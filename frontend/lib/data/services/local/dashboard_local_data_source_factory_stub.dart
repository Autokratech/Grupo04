import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

DashboardLocalDataSource createPlatformDashboardLocalDataSource({
  required SharedPreferences sharedPreferences,
}) {
  throw UnsupportedError('Unsupported platform for dashboard local cache');
}
