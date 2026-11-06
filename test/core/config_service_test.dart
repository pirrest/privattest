import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/core/controller/config_service.dart';

void main() {
  group('ConfigService.fromValues', () {
    test('accepts an absolute http(s) base URL', () {
      expect(
        ConfigService.fromValues(apiBaseUrl: 'https://dummyjson.com')
            .apiBaseUrl,
        'https://dummyjson.com',
      );
      expect(
        ConfigService.fromValues(apiBaseUrl: 'http://localhost:8080')
            .apiBaseUrl,
        'http://localhost:8080',
      );
    });

    test('fails fast when the value is empty, with a hint how to fix it', () {
      expect(
        () => ConfigService.fromValues(apiBaseUrl: ''),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('--dart-define-from-file'),
          ),
        ),
      );
    });

    test('rejects values that are not an absolute http(s) URL', () {
      for (final value in [
        'dummyjson.com',
        '/products',
        'ftp://host',
        'https://',
      ]) {
        expect(
          () => ConfigService.fromValues(apiBaseUrl: value),
          throwsStateError,
          reason: value,
        );
      }
    });
  });
}
