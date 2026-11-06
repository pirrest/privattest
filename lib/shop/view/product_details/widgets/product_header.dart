import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/view/widgets/rating_badge.dart';
import 'package:privat_test/core/view/export.dart';

class ProductHeader extends StatelessWidget {
  final Product product;

  const ProductHeader({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final brand = product.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          [?brand, product.category].join(' · '),
          style: textTheme.bodyMedium?.copyWith(color: colors.outline),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: textTheme.headlineMedium,
            ),
            if (product.discountPercentage > 0) ...[
              const SizedBox(width: 8),
              Text(
                '\$${product.originalPrice.toStringAsFixed(2)}',
                style: textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colors.outline,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '-${product.discountPercentage.toStringAsFixed(0)}%',
                style: textTheme.titleSmall?.copyWith(color: colors.error),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RatingBadge(rating: product.rating),
            const SizedBox(width: 16),
            Text('details.inStock'.tr(args: ['${product.stock}'])),
            if (product.availabilityStatus != null) ...[
              const SizedBox(width: 16),
              Text(product.availabilityStatus!),
            ],
          ],
        ),
      ],
    );
  }
}
