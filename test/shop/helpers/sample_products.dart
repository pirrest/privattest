/// A product in the exact shape dummyjson returns it.
Map<String, dynamic> sampleProductMap({
  int id = 1,
  String title = 'Essence Mascara Lash Princess',
  String description = 'A popular mascara known for its volumizing effects.',
  String category = 'beauty',
}) {
  return {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': 9.99,
    'discountPercentage': 7.17,
    'rating': 4.94,
    'stock': 5,
    'tags': ['beauty', 'mascara'],
    'brand': 'Essence',
    'sku': 'BEA-ESS-ESS-001',
    'weight': 4,
    'dimensions': {'width': 23.17, 'height': 14.43, 'depth': 28.01},
    'warrantyInformation': '1 week warranty',
    'shippingInformation': 'Ships in 1 month',
    'availabilityStatus': 'Low Stock',
    'reviews': [
      {
        'rating': 2,
        'comment': 'Very unhappy with my purchase!',
        'date': '2025-04-30T09:41:02.053Z',
        'reviewerName': 'John Doe',
        'reviewerEmail': 'john.doe@x.dummyjson.com',
      },
    ],
    'returnPolicy': '30 days return policy',
    'minimumOrderQuantity': 24,
    'meta': {'barcode': '5784719087687'},
    'images': ['https://cdn.dummyjson.com/products/images/1/1.webp'],
    'thumbnail': 'https://cdn.dummyjson.com/products/images/1/thumbnail.webp',
  };
}

Map<String, dynamic> searchResponse(
  List<Map<String, dynamic>> products, {
  int? total,
  int skip = 0,
}) {
  return {
    'products': products,
    'total': total ?? products.length,
    'skip': skip,
    'limit': products.length,
  };
}
