import 'package:privat_test/core/view/export.dart';

class ImagePageDots extends StatelessWidget {
  final int count;
  final int index;

  const ImagePageDots({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? colors.primary : colors.outlineVariant,
            ),
          ),
      ],
    );
  }
}
