import 'package:privat_test/shop/controller/shop_api_service.dart';

/// Hand-written fake: set [onGetProducts] / [onSearch] / [onGetProduct] to
/// script the API.
class FakeShopApiService implements ShopApiService {
  Future<Map<String, dynamic>> Function(String query, int limit, int skip)?
  onSearch;
  Future<Map<String, dynamic>> Function(int id)? onGetProduct;

  Future<Map<String, dynamic>> Function(int limit, int skip)? onGetProducts;

  final searchCalls = <({String query, int skip})>[];

  @override
  Future<Map<String, dynamic>> getProducts({
    required int limit,
    required int skip,
  }) => onGetProducts!(limit, skip);

  @override
  Future<Map<String, dynamic>> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) {
    searchCalls.add((query: query, skip: skip));
    return onSearch!(query, limit, skip);
  }

  @override
  Future<Map<String, dynamic>> getProduct(int id) => onGetProduct!(id);
}
