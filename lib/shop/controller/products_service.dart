import 'dart:io';

import 'package:dio/dio.dart';
import 'package:privat_test/core/utils/casting.dart';
import 'package:privat_test/shop/controller/shop_api_service.dart';
import 'package:privat_test/core/controller/logger_service.dart';
import 'package:privat_test/shop/model/exceptions/product_not_found_exception.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/model/products_page.dart';
import 'package:privat_test/shop/model/repositories/products_repo.dart';
import 'package:privat_test/core/utils/dio_extensions.dart';

class ProductsService {
  static const pageSize = 20;

  final ShopApiService _apiService;
  final ProductsRepo _productsRepo;

  ProductsService(this._apiService, this._productsRepo);

  /// Loads one page of products: all products for an empty [query], search
  /// results otherwise. Goes to the API first and caches what it returns; when
  /// there is no connection it reads the local cache instead.
  Future<ProductsPage> loadPage({
    required String query,
    required int skip,
  }) async {
    try {
      final map = query.isEmpty
          ? await _apiService.getProducts(limit: pageSize, skip: skip)
          : await _apiService.searchProducts(
              query: query,
              limit: pageSize,
              skip: skip,
            );
      final products = [
        for (final item in cast<List>(map['products'], orElse: const []))
          if (castOrNull<Map<String, dynamic>>(item) case final itemMap?)
            Product.fromMap(itemMap),
      ];
      await _cache(products);
      return ProductsPage(
        items: products,
        total: cast<num>(map['total'], orElse: products.length).toInt(),
        skip: skip,
      );
    } on DioException catch (e) {
      if (!e.isConnectionFailure) rethrow;

      final items = await _productsRepo.queryPage(
        query: query,
        limit: pageSize,
        skip: skip,
      );
      final total = await _productsRepo.count(query);
      return ProductsPage(items: items, total: total, skip: skip);
    }
  }

  /// Loads a single product by id, falling back to the local cache when
  /// there is no connection. Throws [ProductNotFoundException] when the
  /// product does not exist or is not cached.
  Future<Product> loadProduct(int id) async {
    try {
      final map = await _apiService.getProduct(id);
      final product = Product.fromMap(map);
      await _cache([product]);
      return product;
    } on DioException catch (e) {
      if (e.response?.statusCode == HttpStatus.notFound) {
        throw ProductNotFoundException(id);
      }
      if (!e.isConnectionFailure) rethrow;

      final cached = await _productsRepo.getById(id);
      if (cached == null) throw ProductNotFoundException(id);

      return cached;
    }
  }

  Future<void> _cache(List<Product> products) async {
    try {
      await _productsRepo.upsertAll(products);
    } catch (e, s) {
      // A broken cache must not break the online flow.
      error('Failed to cache products: $e', stack: s);
    }
  }
}
