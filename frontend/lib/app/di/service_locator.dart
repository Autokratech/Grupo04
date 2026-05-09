import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository_impl.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository.dart';
import 'package:frontend/data/repositories/dashboard_repository/dashboard_repository_impl.dart';
import 'package:frontend/data/repositories/profile_repository/profile_repository.dart';
import 'package:frontend/data/repositories/profile_repository/profile_repository_impl.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source.dart';
import 'package:frontend/data/services/local/dashboard_local_data_source_factory.dart';
import 'package:frontend/data/services/local/dashboard_preferences_service.dart';
import 'package:frontend/data/services/local/session_storage_service.dart';
import 'package:frontend/data/services/remote/api_client.dart';
import 'package:frontend/data/services/remote/auth_api_service.dart';
import 'package:frontend/data/services/remote/dashboard_api_service.dart';
import 'package:frontend/data/services/remote/user_api_service.dart';
import 'package:frontend/features/profile/presentation/viewmodels/profile_viewmodel.dart';
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

  // Testing on Android -> http://10.0.2.2:8001
  // Testing on Windows -> http://127.0.0.1:8001
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: 'http://127.0.0.1:8001',
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

  sl.registerLazySingleton<UserApiService>(
    () => UserApiService(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApiService: sl<AuthApiService>(),
      sessionStorageService: sl<SessionStorageService>(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(userApiService: sl<UserApiService>()),
  );

  sl.registerLazySingleton<DashboardLocalDataSource>(
        () => createDashboardLocalDataSource(
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      localDataSource: sl<DashboardLocalDataSource>(),
      apiService: sl<DashboardApiService>(),
      sessionStorageService: sl<SessionStorageService>(),
    ),
  );

  sl.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      profileRepository: sl<ProfileRepository>(),
      authRepository: sl<AuthRepository>(),
    ),
  );
}
