import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/shop/controller/products_service.dart';
import 'package:privat_test/shop/model/exceptions/product_not_found_exception.dart';
import 'package:privat_test/shop/model/repositories/products_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/dio_errors.dart';
import 'helpers/fake_shop_api_service.dart';
import 'helpers/sample_products.dart';

void main() {
  late FakeShopApiService api;
  late ProductsRepo repo;
  late ProductsService service;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    api = FakeShopApiService();
    repo = ProductsRepo(databaseFactoryFfi, inMemoryDatabasePath);
    await repo.init();
    service = ProductsService(api, repo);
  });

  tearDown(() => repo.close());

  group('loadPage', () {
    test('returns API results and caches them', () async {
      api.onSearch = (query, limit, skip) async => searchResponse([
        sampleProductMap(id: 1),
        sampleProductMap(id: 2, title: 'Second'),
      ], total: 7);

      final page = await service.loadPage(query: 'mas', skip: 0);

      expect(page.items.map((p) => p.id), [1, 2]);
      expect(page.total, 7);
      expect(await repo.count(''), 2);
    });

    test('falls back to the cache when there is no connection', () async {
      api.onSearch = (query, limit, skip) async => searchResponse([
        sampleProductMap(id: 1, title: 'Red Mascara'),
        sampleProductMap(
            id: 2,
            title: 'Laptop',
            description: 'A fast notebook computer.',
            category: 'laptops',
          )
          ..['tags'] = ['computers']
          ..['brand'] = 'Acme',
      ]);
      await service.loadPage(query: 'a', skip: 0);

      api.onSearch = (query, limit, skip) async => throw noConnectionError();
      final page = await service.loadPage(query: 'mascara', skip: 0);

      expect(page.items.map((p) => p.id), [1]);
      expect(page.total, 1);
    });

    test(
      'an empty query lists all products from the browse endpoint',
      () async {
        api.onGetProducts = (limit, skip) async => searchResponse([
          sampleProductMap(id: 1),
          sampleProductMap(id: 2, title: 'Second'),
        ], total: 30);

        final page = await service.loadPage(query: '', skip: 20);

        expect(page.items.map((p) => p.id), [1, 2]);
        expect(page.total, 30);
        expect(api.searchCalls, isEmpty);
        expect(await repo.count(''), 2);
      },
    );

    test('an empty query offline lists everything cached', () async {
      api.onGetProducts = (limit, skip) async => searchResponse([
        sampleProductMap(id: 1),
        sampleProductMap(id: 2, title: 'Second'),
      ]);
      await service.loadPage(query: '', skip: 0);

      api.onGetProducts = (limit, skip) async => throw noConnectionError();
      final page = await service.loadPage(query: '', skip: 0);

      expect(page.items.map((p) => p.id), [1, 2]);
    });

    test('rethrows HTTP errors instead of using the cache', () async {
      api.onSearch = (query, limit, skip) async => throw httpError(500);

      expect(
        service.loadPage(query: 'mas', skip: 0),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('loadProduct', () {
    test('returns the API product and caches it', () async {
      api.onGetProduct = (id) async => sampleProductMap(id: id);

      final product = await service.loadProduct(5);

      expect(product.id, 5);
      expect((await repo.getById(5))?.id, 5);
    });

    test('serves a cached product when offline', () async {
      api.onGetProduct = (id) async => sampleProductMap(id: id);
      await service.loadProduct(5);

      api.onGetProduct = (id) async => throw noConnectionError();
      final product = await service.loadProduct(5);

      expect(product.id, 5);
    });

    test('throws ProductNotFoundException when offline and not cached', () {
      api.onGetProduct = (id) async => throw noConnectionError();

      expect(service.loadProduct(99), throwsA(isA<ProductNotFoundException>()));
    });

    test('throws ProductNotFoundException on HTTP 404', () {
      api.onGetProduct = (id) async => throw httpError(404);

      expect(service.loadProduct(99), throwsA(isA<ProductNotFoundException>()));
    });
  });
}
