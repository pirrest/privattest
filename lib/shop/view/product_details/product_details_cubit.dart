import 'package:equatable/equatable.dart';
import 'package:privat_test/core/controller/logger_service.dart';
import 'package:privat_test/shop/controller/products_service.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/core/utils/my_cubit.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends MyCubit<ProductDetailsState> {
  final ProductsService _productsService;
  final int productId;

  ProductDetailsCubit(this._productsService, this.productId)
    : super(const ProductDetailsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final product = await _productsService.loadProduct(productId);
      emit(state.copyWith(product: product, isLoading: false));
    } catch (e, s) {
      error('Failed to load product $productId: $e', stack: s);
      emit(state.copyWith(isLoading: false, error: e));
    }
  }
}
