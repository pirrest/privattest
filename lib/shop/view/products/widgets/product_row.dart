import 'package:privat_test/core/view/app/widgets/cached_image.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/shop/view/widgets/rating_badge.dart';

class ProductRow extends StatelessWidget {
  static const _imageSize = 72.0;

  final Product product;
  final VoidCallback onTap;

  const ProductRow({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: _imageSize,
                child: CachedImage(url: product.thumbnail),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'common.price'.tr(args: [product.price.toStringAsFixed(2)]),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                RatingBadge(rating: product.rating),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
