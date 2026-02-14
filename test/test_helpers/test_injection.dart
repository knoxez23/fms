import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/core/network/token_manager.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';
import 'package:pamoja_twalima/data/services/inventory_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockTokenManager extends Mock implements TokenManager {}

final getIt = GetIt.instance;

void setupTestDependencies() {
  getIt.reset();

  getIt.registerLazySingleton<ApiService>(() => MockApiService());
  getIt.registerLazySingleton<TokenManager>(() => MockTokenManager());
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<ApiService>(), getIt<TokenManager>()),
  );
  getIt.registerLazySingleton<InventoryService>(
    () => InventoryService(getIt<ApiService>()),
  );
}

void teardownTestDependencies() {
  getIt.reset();
}
