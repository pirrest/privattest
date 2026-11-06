import 'package:privat_test/core/view/app/widgets/cached_image.dart';
import 'package:privat_test/core/view/export.dart';
import 'package:privat_test/shop/view/product_details/widgets/image_page_dots.dart';

class ProductImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  final ValueChanged<int> onIndexChanged;

  static String heroTag(String url) => 'product-image-$url';

  const ProductImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.onIndexChanged,
  });

  static Future<void> open(
    BuildContext context, {
    required List<String> images,
    required int initialIndex,
    required ValueChanged<int> onIndexChanged,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductImageViewer(
              images: images,
              initialIndex: initialIndex,
              onIndexChanged: onIndexChanged,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<ProductImageViewer> {
  late final PageController _pageController;
  late int _index;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            // A zoomed image is panned with one finger, so paging is paused.
            physics: _isZoomed ? const NeverScrollableScrollPhysics() : null,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _index = index);
              widget.onIndexChanged(index);
            },
            itemBuilder: (context, index) => _ZoomableImage(
              url: widget.images[index],
              onZoomChanged: (isZoomed) {
                if (index == _index && isZoomed != _isZoomed) {
                  setState(() => _isZoomed = isZoomed);
                }
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  tooltip: 'common.close'.tr(),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ImagePageDots(
                    count: widget.images.length,
                    index: _index,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  static const _maxScale = 5.0;
  static const _doubleTapScale = 2.5;

  final String url;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({required this.url, required this.onZoomChanged});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _controller = TransformationController();
  Offset _doubleTapPosition = Offset.zero;
  bool _isZoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _controller,
        maxScale: _ZoomableImage._maxScale,
        // At normal size one finger belongs to the page swipe.
        panEnabled: _isZoomed,
        onInteractionUpdate: (_) => _syncZoom(),
        onInteractionEnd: (_) => _syncZoom(),
        child: Hero(
          tag: ProductImageViewer.heroTag(widget.url),
          child: CachedImage(url: widget.url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _toggleZoom() {
    if (_isZoomed) {
      _controller.value = Matrix4.identity();
    } else {
      // Zoom in around the tapped point.
      const scale = _ZoomableImage._doubleTapScale;
      final position = _doubleTapPosition;
      _controller.value = Matrix4.identity()
        ..translateByDouble(
          -position.dx * (scale - 1),
          -position.dy * (scale - 1),
          0,
          1,
        )
        ..scaleByDouble(scale, scale, 1, 1);
    }
    _syncZoom();
  }

  void _syncZoom() {
    final isZoomed = _controller.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomed == _isZoomed) return;
    setState(() => _isZoomed = isZoomed);
    widget.onZoomChanged(isZoomed);
  }
}
