import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/shop/controller/products_service.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/model/products_page.dart' as model;
import 'package:privat_test/shop/model/repositories/products_repo.dart';
import 'package:privat_test/shop/view/products/products_cubit.dart';
import 'package:privat_test/shop/view/products/products_page.dart';
import 'package:privat_test/shop/view/products/widgets/product_card.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/fake_shop_api_service.dart';
import 'helpers/sample_products.dart';

/// Serves two products without touching the network or the database.
class _FakeProductsService extends ProductsService {
  final queries = <String>[];

  _FakeProductsService()
    : super(
        FakeShopApiService(),
        ProductsRepo(databaseFactoryFfi, inMemoryDatabasePath),
      );

  @override
  Future<model.ProductsPage> loadPage({
    required String query,
    required int skip,
  }) async {
    queries.add(query);
    final items = [
      Product.fromMap(sampleProductMap(id: 1, title: 'First $query')),
      Product.fromMap(sampleProductMap(id: 2, title: 'Second $query')),
    ];
    return model.ProductsPage(items: items, total: 2, skip: skip);
  }
}

void main() {
  late _FakeProductsService products;

  setUp(() {
    products = _FakeProductsService();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => ProductsCubit(products),
          child: const ProductsPage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows all products first, then reloads for a search', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.byType(ProductCard), findsNWidgets(2));
    expect(products.queries, ['']);

    await tester.enterText(find.byType(TextField), 'ma');
    await tester.pump(ProductsCubit.debounceDuration);
    await tester.pump();
    await tester.pump();

    expect(products.queries, ['', 'ma']);
    expect(find.text('First ma'), findsOneWidget);
  });
}
