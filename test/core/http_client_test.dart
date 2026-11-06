import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/core/controller/connection_service.dart';
import 'package:privat_test/core/controller/http_client.dart';

/// Answers every request with [onFetch].
class _FakeAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options) onFetch;

  _FakeAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int statusCode) {
  return ResponseBody.fromString(
    jsonEncode({'ok': true}),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late ConnectionService connection;
  late HttpClient client;
  late _FakeAdapter adapter;

  setUp(() {
    connection = ConnectionService();
    client = HttpClient(
      baseUrl: 'https://example.test',
      connectionService: connection,
    );
    adapter = _FakeAdapter((_) async => _json(200));
    client.httpClientAdapter = adapter;
  });

  test('a request without a response marks the app offline', () async {
    adapter.onFetch = (options) async => throw DioException.connectionError(
      requestOptions: options,
      reason: 'no network',
    );

    await expectLater(client.get<Object>('/x'), throwsA(isA<DioException>()));

    expect(connection.isOffline, isTrue);
  });

  test('a successful request brings the app back online', () async {
    connection.reportFailure();

    await client.get<Object>('/x');

    expect(connection.isOffline, isFalse);
  });

  test('an HTTP error status does not mark the app offline', () async {
    adapter.onFetch = (_) async => _json(500);

    await expectLater(client.get<Object>('/x'), throwsA(isA<DioException>()));

    expect(connection.isOffline, isFalse);
  });
}
