import 'package:privat_test/shop/model/product_review.dart';
import 'package:privat_test/shop/view/widgets/rating_badge.dart';
import 'package:privat_test/core/view/export.dart';

class ReviewTile extends StatelessWidget {
  final ProductReview review;

  const ReviewTile({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review.reviewerName, style: textTheme.titleSmall),
                RatingBadge(rating: review.rating.toDouble()),
              ],
            ),
            const SizedBox(height: 4),
            Text(review.comment),
          ],
        ),
      ),
    );
  }
}
