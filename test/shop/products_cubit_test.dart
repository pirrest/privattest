import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/shop/controller/products_service.dart';
import 'package:privat_test/shop/model/repositories/products_repo.dart';
import 'package:privat_test/shop/view/products/products_cubit.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/dio_errors.dart';
import 'helpers/fake_shop_api_service.dart';
import 'helpers/sample_products.dart';

void main() {
  late FakeShopApiService api;
  late ProductsRepo repo;
  late ProductsCubit cubit;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    api = FakeShopApiService();
    api.onGetProducts = (limit, skip) async =>
        searchResponse([sampleProductMap(id: 1)], total: 1);
    api.onSearch = (query, limit, skip) async =>
        searchResponse([sampleProductMap(id: 1)], total: 1);
    repo = ProductsRepo(databaseFactoryFfi, inMemoryDatabasePath);
    await repo.init();
    cubit = ProductsCubit(ProductsService(api, repo));
  });

  tearDown(() async {
    await cubit.close();
    await repo.close();
  });

  Future<void> waitForDebounce() => Future<void>.delayed(
    ProductsCubit.debounceDuration + const Duration(milliseconds: 100),
  );

  test('a query shorter than 2 characters never starts a search', () async {
    cubit.onQueryChanged('a');
    await waitForDebounce();

    expect(cubit.state.query, 'a');
    expect(cubit.state.searchQuery, isNull);
  });

  test('a query of 2 characters starts a search after the debounce', () async {
    cubit.onQueryChanged('ma');

    expect(cubit.state.searchQuery, isNull);
    await waitForDebounce();

    expect(cubit.state.searchQuery, 'ma');
  });

  test('typing quickly searches only for the final query', () async {
    cubit.onQueryChanged('ma');
    cubit.onQueryChanged('mas');
    cubit.onQueryChanged('masc');
    await waitForDebounce();

    expect(cubit.state.searchQuery, 'masc');
  });

  test(
    'shrinking the query below 2 characters returns to all products',
    () async {
      cubit.onQueryChanged('ma');
      await waitForDebounce();
      cubit.onQueryChanged('m');

      expect(cubit.state.searchQuery, isNull);
      expect(cubit.state.totalItems, isNull);
    },
  );

  test('loadPage returns products and stores the total', () async {
    cubit.onQueryChanged('mascara');
    await waitForDebounce();

    final items = await cubit.loadPage(0);

    expect(items.map((p) => p.id), [1]);
    expect(cubit.state.totalItems, 1);
  });

  test('the offline flag is set when results come from the cache', () async {
    cubit.onQueryChanged('mascara');
    await waitForDebounce();
    await cubit.loadPage(0);
    expect(cubit.state.isOffline, isFalse);

    api.onSearch = (query, limit, skip) async => throw noConnectionError();
    await cubit.loadPage(0);

    expect(cubit.state.isOffline, isTrue);
  });

  group('browse mode', () {
    test('without a search loadPage lists all products', () async {
      final items = await cubit.loadPage(0);

      expect(items.map((p) => p.id), [1]);
      expect(api.searchCalls, isEmpty);
      expect(cubit.state.totalItems, 1);
    });

    test('shrinking the query goes back to browsing all products', () async {
      cubit.onQueryChanged('ma');
      await waitForDebounce();
      expect(cubit.state.searchQuery, isNotNull);

      cubit.onQueryChanged('');

      expect(cubit.state.searchQuery, isNull);
      await cubit.loadPage(0);
      expect(api.searchCalls, isEmpty);
    });
  });
}
