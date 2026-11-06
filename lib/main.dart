import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:privat_test/core/controller/commands/initialize_app_command.dart';
import 'package:privat_test/core/controller/commands/initialize_app_result.dart';
import 'package:privat_test/shop/dependencies.dart';
import 'package:privat_test/shop/view/navigation/shop_page_path.dart';
import 'package:privat_test/shop/view/navigation/shop_routes.dart';
import 'package:privat_test/core/view/app/theme/theme.dart';
import 'package:privat_test/core/view/app/connection_cubit.dart';
import 'package:privat_test/core/view/app/theme/theme_cubit.dart';
import 'package:privat_test/core/view/app/widgets/offline_banner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:watch_it/watch_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // The composition root: the only place that knows both domains.
  final result = await InitializeAppCommand(
    routes: createShopRoutes(),
    initialLocation: ShopPagePath.products,
    registerDomainDependencies: registerShopDependencies,
  )();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: switch (result) {
        InitializeAppResultSuccess() => const App(),
        InitializeAppResultError(:final error) => InitializationErrorApp(
          error: error,
        ),
      },
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => ConnectionCubit(di())),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;

    return MaterialApp.router(
      onGenerateTitle: (context) => 'products.title'.tr(),
      theme: createMainTheme(brightness: Brightness.light),
      darkTheme: createMainTheme(brightness: Brightness.dark),
      themeMode: themeMode,
      routerConfig: di<GoRouter>(),
      builder: (context, child) {
        final isOffline = context.watch<ConnectionCubit>().state;
        return Column(
          children: [
            if (isOffline) const OfflineBanner(),
            Expanded(
              // The banner already covers the status bar area.
              child: MediaQuery.removePadding(
                context: context,
                removeTop: isOffline,
                child: child!,
              ),
            ),
          ],
        );
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class InitializationErrorApp extends StatelessWidget {
  final Object error;

  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('errors.startFailed'.tr(args: ['$error'])),
          ),
        ),
      ),
    );
  }
}
