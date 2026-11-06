import 'package:dio/dio.dart';

/// What dio throws when the device has no connection (no response at all).
DioException noConnectionError() {
  return DioException(
    requestOptions: RequestOptions(path: '/'),
    type: DioExceptionType.connectionError,
  );
}

DioException httpError(int statusCode) {
  final options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: statusCode),
  );
}
