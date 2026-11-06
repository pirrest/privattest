import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/navigation/shop_page_path.dart';
import 'package:privat_test/shop/view/product_details/product_details_cubit.dart';
import 'package:privat_test/shop/view/product_details/product_details_page.dart';
import 'package:privat_test/shop/view/products/products_cubit.dart';
import 'package:privat_test/shop/view/products/products_page.dart';

List<RouteBase> createShopRoutes() {
  return [
    GoRoute(
      path: ShopPagePath.products,
      builder: (context, state) => BlocProvider(
        create: (_) => ProductsCubit(di()),
        child: const ProductsPage(),
      ),
      routes: [
        GoRoute(
          path: ShopPagePath.productDetails,
          redirect: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return id == null ? ShopPagePath.products : null;
          },
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return BlocProvider(
              create: (_) => ProductDetailsCubit(di(), id)..load(),
              child: const ProductDetailsPage(),
            );
          },
        ),
      ],
    ),
  ];
}
