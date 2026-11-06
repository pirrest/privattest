import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/core/view/app/widgets/offline_banner.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/product_details/widgets/product_header.dart';
import 'package:privat_test/shop/view/product_details/widgets/product_image_gallery.dart';
import 'package:privat_test/shop/view/product_details/widgets/product_reviews.dart';
import 'package:privat_test/shop/view/product_details/widgets/product_specs.dart';

class ProductDetailsBody extends StatelessWidget {
  final Product product;
  final bool isOffline;

  const ProductDetailsBody({
    super.key,
    required this.product,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (isOffline) const OfflineBanner(),
        ProductImageGallery(
          images: product.images.isEmpty ? [product.thumbnail] : product.images,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductHeader(product: product),
              const SizedBox(height: 16),
              Text(
                'details.description'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(product.description),
              if (product.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tag in product.tags) Chip(label: Text(tag)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              ProductSpecs(product: product),
              const SizedBox(height: 16),
              ProductReviews(reviews: product.reviews),
            ],
          ),
        ),
      ],
    );
  }
}
