import 'package:dio/dio.dart';

class HttpClient with DioMixin implements Dio {
  HttpClient({required String baseUrl}) {
    options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    );
    httpClientAdapter = HttpClientAdapter();
  }
}
