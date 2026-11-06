import 'package:privat_test/core/view/app/widgets/error_view.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/product_details/product_details_cubit.dart';
import 'package:privat_test/shop/view/product_details/widgets/product_details_body.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ProductDetailsCubit>();
    final state = cubit.state;
    final product = state.product;

    return Scaffold(
      appBar: AppBar(title: Text('details.title'.tr())),
      body: switch (product) {
        final product? => ProductDetailsBody(
          product: product,
          isOffline: state.isOffline,
        ),
        null when state.isLoading => const Center(
          child: CircularProgressIndicator(),
        ),
        null => ErrorView(error: state.error, onRetry: cubit.load),
      },
    );
  }
}
