import 'package:privat_test/core/model/exceptions/not_found_exception.dart';

/// Thrown when a product is neither available from the API nor cached.
class ProductNotFoundException extends NotFoundException {
  final int id;

  const ProductNotFoundException(this.id);

  @override
  String toString() => 'ProductNotFoundException(id: $id)';
}
