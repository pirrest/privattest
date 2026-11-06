import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:privat_test/core/utils/call_later_extensions.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/view/navigation/shop_page_path.dart';
import 'package:privat_test/core/view/app/widgets/error_view.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/products/products_cubit.dart';
import 'package:privat_test/shop/view/products/widgets/product_card.dart';

class ProductsGrid extends StatefulWidget {
  const ProductsGrid({super.key});

  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  late final PagingController<int, Product> _controller;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProductsCubit>();
    _searchQuery = cubit.state.searchQuery;
    _controller = PagingController<int, Product>(
      getNextPageKey: (state) => _getNextPageKey(cubit, state),
      fetchPage: cubit.loadPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductsCubit>().state;
    _refreshOnSearchChange(state.searchQuery);

    return PagingListener<int, Product>(
      controller: _controller,
      builder: (context, state, fetchNextPage) => RefreshIndicator.adaptive(
        onRefresh: () async => _controller.refresh(),
        child: PagedGridView<int, Product>(
          state: state,
          fetchNextPage: fetchNextPage,
          padding: const EdgeInsets.all(12),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisExtent: 300,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          builderDelegate: PagedChildBuilderDelegate<Product>(
            itemBuilder: (context, product, index) => ProductCard(
              product: product,
              onTap: () {
                FocusScope.of(context).unfocus();
                context.push(ShopPagePath.productDetailsOf(product.id));
              },
            ),
            // Own indicators, so no widget from the package's default
            // (flutter/material based) indicators is used.
            firstPageProgressIndicatorBuilder: (context) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            newPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
            firstPageErrorIndicatorBuilder: (context) => ErrorView(
              error: _controller.value.error,
              onRetry: _controller.fetchNextPage,
            ),
            newPageErrorIndicatorBuilder: (context) => ErrorView(
              error: _controller.value.error,
              onRetry: _controller.fetchNextPage,
            ),
            noItemsFoundIndicatorBuilder: (context) =>
                Center(child: Text('products.noResults'.tr())),
          ),
        ),
      ),
    );
  }

  /// Reloads the grid from the first page when the active search changes. Runs
  /// after the frame, because the controller cannot change while building.
  void _refreshOnSearchChange(String? searchQuery) {
    if (searchQuery == _searchQuery) return;
    _searchQuery = searchQuery;

    _refresh.callOnNextFrame();
  }

  void _refresh() {
    if (mounted) _controller.refresh();
  }

  /// The page key is the number of products already loaded (`skip`).
  /// Returns null once every match has been loaded.
  int? _getNextPageKey(ProductsCubit cubit, PagingState<int, Product> state) {
    if (state.keys == null) return 0;

    final loaded = state.items?.length ?? 0;
    final total = cubit.state.totalItems;
    if (total != null && loaded >= total) return null;
    return loaded;
  }
}
