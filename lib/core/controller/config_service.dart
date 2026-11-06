/// Typed app configuration. Values are compiled in with
/// `--dart-define-from-file=config/<env>.json`, so they are plain,
/// non-secret settings: anything shipped in an app can be extracted.
class ConfigService {
  final String apiBaseUrl;

  const ConfigService._(this.apiBaseUrl);

  factory ConfigService.fromEnvironment() {
    return ConfigService.fromValues(
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    );
  }

  factory ConfigService.fromValues({required String apiBaseUrl}) {
    final uri = Uri.tryParse(apiBaseUrl);
    final isValid =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isValid) {
      throw StateError(
        'API_BASE_URL is missing or invalid ("$apiBaseUrl"). '
        'Run the app with --dart-define-from-file=config/dev.json '
        '(or stg.json / prod.json).',
      );
    }
    return ConfigService._(apiBaseUrl);
  }
}
