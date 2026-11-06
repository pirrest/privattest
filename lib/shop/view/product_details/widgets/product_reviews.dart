import 'package:privat_test/shop/model/product_review.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/product_details/widgets/review_tile.dart';

class ProductReviews extends StatelessWidget {
  final List<ProductReview> reviews;

  const ProductReviews({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.reviews'.tr(args: ['${reviews.length}']),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        for (final review in reviews) ReviewTile(review: review),
      ],
    );
  }
}
