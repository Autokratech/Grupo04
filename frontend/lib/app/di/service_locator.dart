import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository_impl.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository_impl.dart';
import 'package:frontend/data/services/local/dashboard_database_service.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/data/services/local/session_storage_service.dart';
import 'package:frontend/data/services/remote/api_client.dart';
import 'package:frontend/data/services/remote/auth_api_service.dart';
import 'package:frontend/data/services/remote/dashboard_api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  sl.registerLazySingleton<SessionStorageService>(
    () => SessionStorageService(sharedPreferences: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<DashboardPreferencesService>(
    () =>
        DashboardPreferencesService(sharedPreferences: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Testing on Android -> http://10.0.2.2:8000
  // Testing on Windows -> http://127.0.0.1:8000
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'http://127.0.0.1:8000',
      client: sl<http.Client>(),
      sessionStorageService: sl<SessionStorageService>(),
    ),
  );

  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<DashboardApiService>(
    () => DashboardApiService(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApiService: sl<AuthApiService>(),
      sessionStorageService: sl<SessionStorageService>(),
    ),
  );

  sl.registerLazySingleton<DashboardDatabaseService>(
    () => DashboardDatabaseService(),
  );

  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSource(
      databaseService: sl<DashboardDatabaseService>(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      localDataSource: sl<DashboardLocalDataSource>(),
      apiService: sl<DashboardApiService>(),
      sessionStorageService: sl<SessionStorageService>(),
    ),
  );
}
