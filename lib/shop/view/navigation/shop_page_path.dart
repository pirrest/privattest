mixin ShopPagePath {
  static const products = '/';
  static const productDetails = 'product/:id';

  static String productDetailsOf(int id) => '/product/$id';
}
