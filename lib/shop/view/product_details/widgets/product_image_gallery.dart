import 'package:privat_test/core/view/app/widgets/cached_image.dart';
import 'package:privat_test/core/view/export.dart';

class ProductImageGallery extends StatefulWidget {
  final List<String> images;

  const ProductImageGallery({super.key, required this.images});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: PageView(
            onPageChanged: (index) => setState(() => _index = index),
            children: [
              for (final url in widget.images)
                CachedImage(url: url, fit: BoxFit.contain),
            ],
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.images.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _index
                          ? colors.primary
                          : colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
