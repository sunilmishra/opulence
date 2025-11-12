import 'package:aurora_demo/elegance/data/elegance_repository.dart';
import 'package:aurora_demo/elegance/data/elegance_service.dart';
import 'package:aurora_demo/elegance/domain/repository.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

DependencyContext get dependencyContext => DependencyContext.instance;

/// A class that sets up and provides access to dependencies using GetIt.
/// This class registers services and repositories for dependency injection.
/// Note: it follows the Service Locator pattern.
class DependencyContext {
  DependencyContext() : getIt = _setup();

  static final instance = DependencyContext();

  late GetIt getIt;

  /// Registers a type [T] and returns the instance.
  T get<T extends Object>({String? instanceName}) {
    return getIt<T>(instanceName: instanceName);
  }

  Future<void> allReady() async {
    await getIt.allReady();
  }

  Future<void> reset<T extends Object>() async {
    await getIt.resetLazySingleton<T>();
  }

  static GetIt _setup() {
    final getIt = GetIt.instance;

    // Register services
    getIt.registerLazySingleton<EleganceService>(
      () => EleganceService(client: http.Client()),
    );

    // Register repositories
    getIt.registerLazySingleton<EleganceRepository>(
      () => EleganceRepositoryImpl(service: getIt<EleganceService>()),
    );
    return getIt;
  }
}
