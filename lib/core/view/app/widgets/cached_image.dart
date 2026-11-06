import 'package:cached_network_image/cached_network_image.dart';
import 'package:privat_test/core/view/export.dart';

/// Network image that is cached on disk, so it also shows up offline.
class CachedImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const CachedImage({super.key, required this.url, this.fit = BoxFit.cover});

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
      errorWidget: (context, url, error) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Icon(Icons.image_not_supported_outlined, color: colors.outline),
      ),
    );
  }
}
