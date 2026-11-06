import 'package:go_router/go_router.dart';
import 'package:privat_test/core/controller/commands/initialize_app_result.dart';
import 'package:privat_test/core/controller/config_service.dart';
import 'package:privat_test/core/controller/connection_service.dart';
import 'package:privat_test/core/controller/http_client.dart';
import 'package:privat_test/core/controller/logger_service.dart';
import 'package:watch_it/watch_it.dart';

class InitializeAppCommand {
  final List<RouteBase> routes;
  final String initialLocation;
  final Future<void> Function() registerDomainDependencies;

  InitializeAppCommand({
    required this.routes,
    required this.initialLocation,
    required this.registerDomainDependencies,
  });

  Future<InitializeAppResult> call() async {
    try {
      di.registerSingleton(LoggerService());
      di.registerSingleton(ConfigService.fromEnvironment());
      di.registerSingleton(ConnectionService());
      di.registerLazySingleton(
        () => HttpClient(
          baseUrl: di<ConfigService>().apiBaseUrl,
          connectionService: di(),
        ),
      );
      di.registerLazySingleton<GoRouter>(
        () => GoRouter(initialLocation: initialLocation, routes: routes),
      );

      await registerDomainDependencies();

      return const InitializeAppResultSuccess();
    } catch (e, s) {
      error('App initialization failed: $e', stack: s);
      return InitializeAppResultError(e, s);
    }
  }
}
