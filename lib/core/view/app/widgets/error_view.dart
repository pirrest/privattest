import 'package:dio/dio.dart';
import 'package:privat_test/core/model/exceptions/not_found_exception.dart';
import 'package:privat_test/core/view/export.dart';

class ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(_messageKey.tr(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text('common.retry'.tr())),
          ],
        ),
      ),
    );
  }

  String get _messageKey {
    final error = this.error;
    if (error is NotFoundException) return 'errors.notFound';
    if (error is DioException && error.response == null) {
      return 'errors.noConnection';
    }
    return 'errors.tryAgainLater';
  }
}
