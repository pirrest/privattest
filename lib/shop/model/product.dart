import 'package:equatable/equatable.dart';
import 'package:privat_test/core/utils/casting.dart';
import 'package:privat_test/shop/model/product_dimensions.dart';
import 'package:privat_test/shop/model/product_review.dart';

class Product extends Equatable {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final String? sku;
  final double? weight;
  final ProductDimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<ProductReview> reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final List<String> images;
  final String thumbnail;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    this.tags = const [],
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews = const [],
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.images = const [],
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final dimensions = castOrNull<Map<String, dynamic>>(map['dimensions']);
    return Product(
      id: cast<num>(map['id'], orElse: 0).toInt(),
      title: cast<String>(map['title'], orElse: ''),
      description: cast<String>(map['description'], orElse: ''),
      category: cast<String>(map['category'], orElse: ''),
      price: cast<num>(map['price'], orElse: 0).toDouble(),
      discountPercentage: cast<num>(
        map['discountPercentage'],
        orElse: 0,
      ).toDouble(),
      rating: cast<num>(map['rating'], orElse: 0).toDouble(),
      stock: cast<num>(map['stock'], orElse: 0).toInt(),
      tags: _stringList(map['tags']),
      brand: castOrNull<String>(map['brand']),
      sku: castOrNull<String>(map['sku']),
      weight: castOrNull<num>(map['weight'])?.toDouble(),
      dimensions: dimensions == null
          ? null
          : ProductDimensions.fromMap(dimensions),
      warrantyInformation: castOrNull<String>(map['warrantyInformation']),
      shippingInformation: castOrNull<String>(map['shippingInformation']),
      availabilityStatus: castOrNull<String>(map['availabilityStatus']),
      reviews: [
        for (final review in cast<List>(map['reviews'], orElse: const []))
          if (castOrNull<Map<String, dynamic>>(review) case final reviewMap?)
            ProductReview.fromMap(reviewMap),
      ],
      returnPolicy: castOrNull<String>(map['returnPolicy']),
      minimumOrderQuantity: castOrNull<num>(map['minimumOrderQuantity'])
          ?.toInt(),
      images: _stringList(map['images']),
      thumbnail: cast<String>(map['thumbnail'], orElse: ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions?.toMap(),
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': [for (final review in reviews) review.toMap()],
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  /// Price before the discount was applied.
  double get originalPrice {
    if (discountPercentage <= 0 || discountPercentage >= 100) return price;
    return price / (1 - discountPercentage / 100);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    price,
    discountPercentage,
    rating,
    stock,
    tags,
    brand,
    sku,
    weight,
    dimensions,
    warrantyInformation,
    shippingInformation,
    availabilityStatus,
    reviews,
    returnPolicy,
    minimumOrderQuantity,
    images,
    thumbnail,
  ];

  static List<String> _stringList(dynamic value) {
    return [
      for (final item in cast<List>(value, orElse: const [])) item.toString(),
    ];
  }
}
