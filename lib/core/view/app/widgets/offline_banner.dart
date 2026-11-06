import 'package:privat_test/core/view/export.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // The banner sits above the Navigator, so it needs its own Material.
    return Material(
      color: colors.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 18,
                color: colors.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'common.offlineBanner'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
