import 'package:flutter_test/flutter_test.dart';
import 'package:privat_test/core/controller/connection_service.dart';
import 'package:privat_test/core/controller/connection_service_event.dart';

void main() {
  late ConnectionService service;
  late List<bool> changes;

  setUp(() {
    service = ConnectionService();
    changes = [];
    service.addListenerOf<ConnectionServiceEventChanged>(
      (event) => changes.add(event.isOffline),
    );
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('starts online', () {
    expect(service.isOffline, isFalse);
  });

  test('a failure marks it offline and notifies once', () async {
    service.reportFailure();
    service.reportFailure();
    await flush();

    expect(service.isOffline, isTrue);
    expect(changes, [true]);
  });

  test('a success after a failure brings it back online', () async {
    service.reportFailure();
    service.reportSuccess();
    service.reportSuccess();
    await flush();

    expect(service.isOffline, isFalse);
    expect(changes, [true, false]);
  });
}
