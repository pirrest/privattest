import 'package:privat_test/shop/controller/shop_api_paths.dart';
import 'package:privat_test/core/controller/http_client.dart';

class ShopApiService {
  final HttpClient _client;

  ShopApiService(this._client);

  Future<Map<String, dynamic>> getProducts({
    required int limit,
    required int skip,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ShopApiPaths.products,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ShopApiPaths.productsSearch,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ShopApiPaths.product(id),
    );
    return response.data!;
  }
}
