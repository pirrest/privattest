import 'package:path/path.dart' as p;
import 'package:privat_test/shop/controller/products_service.dart';
import 'package:privat_test/shop/controller/shop_api_service.dart';
import 'package:privat_test/shop/model/repositories/products_repo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:watch_it/watch_it.dart';

Future<void> registerShopDependencies() async {
  final productsRepo = ProductsRepo(
    databaseFactory,
    p.join(await getDatabasesPath(), 'products.db'),
  );
  await productsRepo.init();
  di.registerSingleton(productsRepo);

  di.registerLazySingleton(() => ShopApiService(di()));
  di.registerLazySingleton(() => ProductsService(di(), di()));
}
