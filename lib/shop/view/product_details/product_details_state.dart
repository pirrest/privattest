part of 'product_details_cubit.dart';

class ProductDetailsState extends Equatable {
  final Product? product;
  final bool isLoading;
  final Object? error;

  /// True when the product was served from the local cache.
  final bool isOffline;

  const ProductDetailsState({
    this.product,
    this.isLoading = true,
    this.error,
    this.isOffline = false,
  });

  ProductDetailsState copyWith({
    Product? product,
    bool? isLoading,
    Object? error,
    bool clearError = false,
    bool? isOffline,
  }) {
    return ProductDetailsState(
      product: product ?? this.product,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [product, isLoading, error, isOffline];
}
