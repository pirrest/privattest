import 'package:dio/dio.dart';
import 'package:privat_test/core/controller/connection_service.dart';
import 'package:privat_test/core/utils/dio_extensions.dart';

class HttpClient with DioMixin implements Dio {
  HttpClient({
    required String baseUrl,
    required ConnectionService connectionService,
  }) {
    options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    );
    httpClientAdapter = HttpClientAdapter();

    interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          connectionService.reportSuccess();
          handler.next(response);
        },
        onError: (error, handler) {
          // An HTTP error status still means the server answered.
          if (error.isConnectionFailure) {
            connectionService.reportFailure();
          } else {
            connectionService.reportSuccess();
          }
          handler.next(error);
        },
      ),
    );
  }
}
