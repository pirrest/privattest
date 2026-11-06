part of 'product_details_cubit.dart';

class ProductDetailsState extends Equatable {
  final Product? product;
  final bool isLoading;
  final Object? error;

  const ProductDetailsState({this.product, this.isLoading = true, this.error});

  ProductDetailsState copyWith({
    Product? product,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return ProductDetailsState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [product, isLoading, error];
}
