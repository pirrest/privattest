mixin ShopApiPaths {
  static const products = '/products';
  static const productsSearch = '/products/search';

  static String product(int id) => '/products/$id';
}
