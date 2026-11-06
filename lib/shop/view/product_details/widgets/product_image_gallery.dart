import 'package:privat_test/core/view/app/widgets/cached_image.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/product_details/widgets/image_page_dots.dart';
import 'package:privat_test/shop/view/product_details/widgets/product_image_viewer.dart';

class ProductImageGallery extends StatefulWidget {
  final List<String> images;

  final String fallbackUrl;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.fallbackUrl,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _index = index),
            children: [
              for (var i = 0; i < widget.images.length; i++)
                GestureDetector(
                  onTap: () => _openViewer(i),
                  child: Hero(
                    tag: ProductImageViewer.heroTag(widget.images[i]),
                    child: CachedImage(
                      url: widget.images[i],
                      fit: BoxFit.contain,
                      fallbackUrl: i == 0 ? widget.fallbackUrl : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.images.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ImagePageDots(count: widget.images.length, index: _index),
          ),
      ],
    );
  }

  void _openViewer(int index) {
    ProductImageViewer.open(
      context,
      images: widget.images,
      fallbackUrl: widget.fallbackUrl,
      initialIndex: index,
      // Keeps the gallery on the image the viewer shows.
      onIndexChanged: _pageController.jumpToPage,
    );
  }
}
