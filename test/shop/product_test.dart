import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/shop/model/product.dart';

import 'helpers/sample_products.dart';

void main() {
  group('Product', () {
    test('fromMap parses a dummyjson product', () {
      final product = Product.fromMap(sampleProductMap());

      expect(product.id, 1);
      expect(product.title, 'Essence Mascara Lash Princess');
      expect(product.price, 9.99);
      expect(product.rating, 4.94);
      expect(product.stock, 5);
      expect(product.tags, ['beauty', 'mascara']);
      expect(product.brand, 'Essence');
      expect(product.weight, 4.0);
      expect(product.dimensions?.depth, 28.01);
      expect(product.reviews.single.reviewerName, 'John Doe');
      expect(product.images, hasLength(1));
      expect(product.minimumOrderQuantity, 24);
    });

    test('fromMap tolerates a missing brand and optional sections', () {
      final map = sampleProductMap()
        ..remove('brand')
        ..remove('dimensions')
        ..remove('reviews')
        ..remove('tags');

      final product = Product.fromMap(map);

      expect(product.brand, isNull);
      expect(product.dimensions, isNull);
      expect(product.reviews, isEmpty);
      expect(product.tags, isEmpty);
    });

    test('fromMap does not throw on values of an unexpected type', () {
      final map = sampleProductMap()
        ..['price'] = 'cheap'
        ..['rating'] = [4.5]
        ..['stock'] = '5'
        ..['weight'] = true
        ..['minimumOrderQuantity'] = {};

      final product = Product.fromMap(map);

      expect(product.price, 0);
      expect(product.rating, 0);
      expect(product.stock, 0);
      expect(product.weight, isNull);
      expect(product.minimumOrderQuantity, isNull);
    });

    test('toMap and fromMap round trip', () {
      final product = Product.fromMap(sampleProductMap());

      expect(Product.fromMap(product.toMap()), product);
    });

    test('originalPrice undoes the discount', () {
      final product = Product.fromMap(
        sampleProductMap()
          ..['price'] = 90
          ..['discountPercentage'] = 10,
      );

      expect(product.originalPrice, closeTo(100, 0.001));
    });
  });
}
