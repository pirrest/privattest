import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/model/repositories/products_repo.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/sample_products.dart';

Product _product(int id, String title, {String description = 'Some item'}) {
  return Product.fromMap(
    sampleProductMap(id: id, title: title, description: description),
  );
}

void main() {
  late ProductsRepo repo;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    repo = ProductsRepo(databaseFactoryFfi, inMemoryDatabasePath);
    await repo.init();
  });

  tearDown(() => repo.close());

  test('upsertAll stores products and getById returns them', () async {
    await repo.upsertAll([_product(1, 'Mascara')]);

    expect(await repo.getById(1), _product(1, 'Mascara'));
    expect(await repo.getById(2), isNull);
  });

  test('upsertAll replaces an existing product', () async {
    await repo.upsertAll([_product(1, 'Old title')]);
    await repo.upsertAll([_product(1, 'New title')]);

    expect((await repo.getById(1))?.title, 'New title');
    expect(await repo.count(''), 1);
  });

  test(
    'queryPage matches case-insensitively in title and description',
    () async {
      await repo.upsertAll([
        _product(1, 'Red Lipstick'),
        _product(2, 'Blue Phone', description: 'Has a lipstick-sized camera'),
        _product(3, 'Laptop'),
      ]);

      final result = await repo.queryPage(
        query: 'LIPSTICK',
        limit: 10,
        skip: 0,
      );

      expect(result.map((p) => p.id), [1, 2]);
      expect(await repo.count('lipstick'), 2);
    },
  );

  test('queryPage paginates ordered by id', () async {
    await repo.upsertAll([for (var i = 1; i <= 5; i++) _product(i, 'Item $i')]);

    final first = await repo.queryPage(query: 'item', limit: 2, skip: 0);
    final second = await repo.queryPage(query: 'item', limit: 2, skip: 2);
    final third = await repo.queryPage(query: 'item', limit: 2, skip: 4);

    expect(first.map((p) => p.id), [1, 2]);
    expect(second.map((p) => p.id), [3, 4]);
    expect(third.map((p) => p.id), [5]);
  });

  test('LIKE wildcards in the query are treated literally', () async {
    await repo.upsertAll([_product(1, '100% cotton'), _product(2, 'Plain')]);

    final result = await repo.queryPage(query: '%', limit: 10, skip: 0);

    expect(result.map((p) => p.id), [1]);
  });
}
