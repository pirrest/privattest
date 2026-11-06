import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:privat_test/shop/controller/products_service.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/view/products/products_view_mode.dart';
import 'package:privat_test/core/utils/my_cubit.dart';

part 'products_state.dart';

class ProductsCubit extends MyCubit<ProductsState> {
  static const minQueryLength = 2;
  static const debounceDuration = Duration(seconds: 1);

  final ProductsService _productsService;
  Timer? _debounce;

  ProductsCubit(this._productsService) : super(const ProductsState());

  /// Called on every change of the search field.
  void onQueryChanged(String text) {
    final query = text.trim();
    _debounce?.cancel();
    if (query == state.query) return;

    if (query.length < minQueryLength) {
      emit(
        state.copyWith(query: query, clearSearchQuery: true, clearTotal: true),
      );
      return;
    }

    emit(state.copyWith(query: query));
    _debounce = Timer(debounceDuration, () => _startSearch(query));
  }

  /// Switches between the grid and the table view.
  void onViewModeToggled() {
    emit(state.copyWith(viewMode: state.viewMode.toggled));
  }

  /// Loads the page that starts at [skip]: search results for the active
  /// search, or all products when there is none. Used as the fetch callback of
  /// the paging controller.
  Future<List<Product>> loadPage(int skip) async {
    final query = state.searchQuery ?? '';

    final page = await _productsService.loadPage(query: query, skip: skip);
    if ((state.searchQuery ?? '') != query) return const [];

    emit(state.copyWith(totalItems: page.total));
    return page.items;
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void _startSearch(String query) {
    if (state.query != query) return;
    emit(state.copyWith(searchQuery: query, clearTotal: true));
  }
}
