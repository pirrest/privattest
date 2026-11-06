import 'package:privat_test/shop/model/product.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/product_details/widgets/info_row.dart';

class ProductSpecs extends StatelessWidget {
  final Product product;

  const ProductSpecs({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final dimensions = product.dimensions;
    final rows = <(String, String)>[
      if (product.sku != null) ('details.sku', product.sku!),
      if (product.weight != null) ('details.weight', '${product.weight}'),
      if (dimensions != null)
        (
          'details.dimensions',
          '${dimensions.width} × ${dimensions.height} × ${dimensions.depth}',
        ),
      if (product.warrantyInformation != null)
        ('details.warranty', product.warrantyInformation!),
      if (product.shippingInformation != null)
        ('details.shipping', product.shippingInformation!),
      if (product.returnPolicy != null)
        ('details.returnPolicy', product.returnPolicy!),
      if (product.minimumOrderQuantity != null)
        ('details.minimumOrder', '${product.minimumOrderQuantity}'),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.specifications'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        for (final (labelKey, value) in rows)
          InfoRow(label: labelKey.tr(), value: value),
      ],
    );
  }
}
