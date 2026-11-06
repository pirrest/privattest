import 'package:cached_network_image/cached_network_image.dart';
import 'package:privat_test/core/view/export.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  final String? fallbackUrl;

  const CachedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => ColoredBox(
        color: colors.surface,
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        final fallbackUrl = this.fallbackUrl;
        if (fallbackUrl == null) return _brokenImage(colors);

        return CachedNetworkImage(
          imageUrl: fallbackUrl,
          fit: fit,
          errorWidget: (context, url, error) => _brokenImage(colors),
        );
      },
    );
  }

  Widget _brokenImage(ColorScheme colors) {
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported_outlined, color: colors.outline),
    );
  }
}
