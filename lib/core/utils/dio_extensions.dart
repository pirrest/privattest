import 'package:dio/dio.dart';

extension DioExceptionExtension on DioException {
  /// A [DioException] without a response means the request never reached the
  /// server (offline, DNS failure, timeout).
  bool get isConnectionFailure => response == null;
}
