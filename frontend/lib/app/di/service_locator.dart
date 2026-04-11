import 'package:frontend/data/repositories/auth_repository/auth_repository.dart';
import 'package:frontend/data/repositories/auth_repository/auth_repository_impl.dart';
import 'package:frontend/data/services/remote/api_client.dart';
import 'package:frontend/data/services/remote/auth_api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerLazySingleton<http.Client>(() => http.Client());

  sl.registerLazySingleton<ApiClient>(
    () =>
        ApiClient(baseUrl: 'http://127.0.0.1:8000', client: sl<http.Client>()),
  );

  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authApiService: sl<AuthApiService>()),
  );
}
