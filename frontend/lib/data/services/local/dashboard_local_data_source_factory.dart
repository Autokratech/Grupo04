import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_local_data_source_factory_stub.dart'
    if (dart.library.io) 'dashboard_local_data_source_factory_io.dart'
    if (dart.library.html) 'dashboard_local_data_source_factory_web.dart';

DashboardLocalDataSource createDashboardLocalDataSource({
  required SharedPreferences sharedPreferences,
}) {
  return createPlatformDashboardLocalDataSource(
    sharedPreferences: sharedPreferences,
  );
}
