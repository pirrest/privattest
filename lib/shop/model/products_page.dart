import 'package:equatable/equatable.dart';
import 'package:privat_test/shop/model/product.dart';

class ProductsPage extends Equatable {
  final List<Product> items;
  final int total;
  final int skip;

  /// True when the page was built from the local cache instead of the API.
  final bool fromCache;

  const ProductsPage({
    required this.items,
    required this.total,
    required this.skip,
    this.fromCache = false,
  });

  @override
  List<Object?> get props => [items, total, skip, fromCache];
}
