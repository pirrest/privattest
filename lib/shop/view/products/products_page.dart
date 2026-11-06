import 'package:privat_test/core/view/app/widgets/offline_banner.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/products/products_cubit.dart';
import 'package:privat_test/shop/view/products/widgets/products_grid.dart';
import 'package:privat_test/shop/view/products/widgets/products_search_field.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text('products.title'.tr())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: ProductsSearchField(
              controller: _searchController,
              onChanged: context.read<ProductsCubit>().onQueryChanged,
            ),
          ),
          if (state.isOffline) const OfflineBanner(),
          const Expanded(child: ProductsGrid()),
        ],
      ),
    );
  }
}
