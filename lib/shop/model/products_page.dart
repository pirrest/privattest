import 'package:equatable/equatable.dart';
import 'package:privat_test/shop/model/product.dart';

class ProductsPage extends Equatable {
  final List<Product> items;
  final int total;
  final int skip;

  const ProductsPage({
    required this.items,
    required this.total,
    required this.skip,
  });

  @override
  List<Object?> get props => [items, total, skip];
}
