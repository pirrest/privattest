part of 'products_cubit.dart';

class ProductsState extends Equatable {
  /// Text typed by the user, trimmed.
  final String query;

  /// The query results are currently loaded for. Null while the query is
  /// shorter than [ProductsCubit.minQueryLength]; all products are listed then.
  final String? searchQuery;

  /// Total number of matches for [searchQuery], known after the first page.
  final int? totalItems;

  const ProductsState({this.query = '', this.searchQuery, this.totalItems});

  ProductsState copyWith({
    String? query,
    String? searchQuery,
    bool clearSearchQuery = false,
    int? totalItems,
    bool clearTotal = false,
  }) {
    return ProductsState(
      query: query ?? this.query,
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      totalItems: clearTotal ? null : totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [query, searchQuery, totalItems];
}
