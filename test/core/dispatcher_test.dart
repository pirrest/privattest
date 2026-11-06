import 'package:privat_test/core/utils/dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Test event hierarchy
// ---------------------------------------------------------------------------

abstract class _AppEvent {}

class _LoginEvent extends _AppEvent {
  _LoginEvent(this.userId);

  final String userId;
}

class _LogoutEvent extends _AppEvent {}

class _OtherEvent extends _AppEvent {}

// Helper that flushes pending microtasks scheduled by `scheduleMicrotask`.
Future<void> _flushMicrotasks() => Future<void>.delayed(Duration.zero);

// A class that uses the mixin for mixin-related tests.
class _TestBus with DispatcherMixin<_AppEvent> {}

void main() {
  group('Dispatcher', () {
    late Dispatcher<_AppEvent> dispatcher;

    setUp(() {
      dispatcher = Dispatcher<_AppEvent>();
    });

    test('initial lastEvent is null', () {
      expect(dispatcher.lastEvent, isNull);
    });

    test('dispatch updates lastEvent synchronously', () {
      final event = _LoginEvent('u1');

      dispatcher.dispatch(event);

      expect(dispatcher.lastEvent, same(event));
    });

    test('listener is invoked asynchronously (in a microtask)', () async {
      final received = <_AppEvent>[];
      dispatcher.addListener(received.add);

      final event = _LoginEvent('u1');
      dispatcher.dispatch(event);

      // Listener should NOT have been invoked yet — dispatch schedules a microtask.
      expect(received, isEmpty);

      await _flushMicrotasks();

      expect(received, [same(event)]);
    });

    test('multiple listeners all receive the dispatched event', () async {
      final a = <_AppEvent>[];
      final b = <_AppEvent>[];

      dispatcher.addListener(a.add);
      dispatcher.addListener(b.add);

      final event = _LogoutEvent();
      dispatcher.dispatch(event);
      await _flushMicrotasks();

      expect(a, [same(event)]);
      expect(b, [same(event)]);
    });

    test('the same listener is not added twice', () async {
      var callCount = 0;
      void listener(_AppEvent _) => callCount++;

      dispatcher.addListener(listener);
      dispatcher.addListener(listener); // duplicate

      dispatcher.dispatch(_LogoutEvent());
      await _flushMicrotasks();

      expect(callCount, 1);
    });

    test('removeListener prevents subsequent invocations', () async {
      var callCount = 0;
      void listener(_AppEvent _) => callCount++;

      dispatcher.addListener(listener);
      dispatcher.removeListener(listener);

      dispatcher.dispatch(_LogoutEvent());
      await _flushMicrotasks();

      expect(callCount, 0);
    });

    test('removeListener of unknown listener is a no-op', () {
      void listener(_AppEvent _) {}

      // Should not throw.
      expect(() => dispatcher.removeListener(listener), returnsNormally);
    });

    test('removeAllListeners clears every registered listener', () async {
      var aCalls = 0;
      var bCalls = 0;

      dispatcher.addListener((_) => aCalls++);
      dispatcher.addListener((_) => bCalls++);

      dispatcher.removeAllListeners();

      dispatcher.dispatch(_LogoutEvent());
      await _flushMicrotasks();

      expect(aCalls, 0);
      expect(bCalls, 0);
      expect(dispatcher.listeners, isEmpty);
    });

    test('modifying listeners during dispatch does not throw '
        '(snapshot is iterated)', () async {
      final received = <String>[];

      void second(_AppEvent _) => received.add('second');

      void first(_AppEvent _) {
        received.add('first');
        // Mutate the listeners set during dispatch.
        dispatcher.removeListener(second);
        dispatcher.addListener((_) => received.add('added-during-dispatch'));
      }

      dispatcher.addListener(first);
      dispatcher.addListener(second);

      dispatcher.dispatch(_LogoutEvent());
      await _flushMicrotasks();

      // Both originally registered listeners should have run on this dispatch.
      expect(received, containsAll(<String>['first', 'second']));
      // The listener added during dispatch must NOT fire for this event.
      expect(received, isNot(contains('added-during-dispatch')));
    });

    test('listener added during dispatch fires on the NEXT dispatch', () async {
      final received = <String>[];

      void lateListener(_AppEvent _) => received.add('late');

      dispatcher.addListener((_) {
        dispatcher.addListener(lateListener);
      });

      dispatcher.dispatch(_LogoutEvent());
      await _flushMicrotasks();
      expect(received, isEmpty);

      dispatcher.dispatch(_LogoutEvent());
      await _flushMicrotasks();
      expect(received, ['late']);
    });

    group('typed addListenerOf<E>', () {
      test('typed listener fires only for matching subtype', () async {
        final loginEvents = <_LoginEvent>[];
        final logoutEvents = <_LogoutEvent>[];

        dispatcher.addListenerOf<_LoginEvent>(loginEvents.add);
        dispatcher.addListenerOf<_LogoutEvent>(logoutEvents.add);

        final login = _LoginEvent('u1');
        dispatcher.dispatch(login);
        await _flushMicrotasks();

        expect(loginEvents, [same(login)]);
        expect(logoutEvents, isEmpty);

        final logout = _LogoutEvent();
        dispatcher.dispatch(logout);
        await _flushMicrotasks();

        expect(loginEvents, [same(login)]);
        expect(logoutEvents, [same(logout)]);
      });

      test('typed listener does not fire for unrelated subtype', () async {
        var callCount = 0;
        dispatcher.addListenerOf<_LoginEvent>((_) => callCount++);

        dispatcher.dispatch(_OtherEvent());
        await _flushMicrotasks();

        expect(callCount, 0);
      });

      test(
        'untyped listener (E defaults to Event) receives all event types',
        () async {
          final received = <_AppEvent>[];
          dispatcher.addListener(received.add);

          final login = _LoginEvent('u');
          final logout = _LogoutEvent();
          final other = _OtherEvent();

          dispatcher
            ..dispatch(login)
            ..dispatch(logout)
            ..dispatch(other);
          await _flushMicrotasks();

          expect(received, [same(login), same(logout), same(other)]);
        },
      );

      test('typed and untyped listeners coexist and each receive what they '
          'should', () async {
        final allEvents = <_AppEvent>[];
        final loginEvents = <_LoginEvent>[];

        dispatcher.addListener(allEvents.add);
        dispatcher.addListenerOf<_LoginEvent>(loginEvents.add);

        final login = _LoginEvent('u');
        final logout = _LogoutEvent();

        dispatcher
          ..dispatch(login)
          ..dispatch(logout);
        await _flushMicrotasks();

        expect(allEvents, [same(login), same(logout)]);
        expect(loginEvents, [same(login)]);
      });

      test('typed listener can be removed by the same reference', () async {
        var callCount = 0;
        void listener(_LoginEvent _) => callCount++;

        dispatcher.addListenerOf<_LoginEvent>(listener);
        dispatcher.removeListener(listener);

        dispatcher.dispatch(_LoginEvent('u'));
        await _flushMicrotasks();

        expect(callCount, 0);
      });

      test('adding the same typed listener twice deduplicates', () async {
        var callCount = 0;
        void listener(_LoginEvent _) => callCount++;

        dispatcher
          ..addListenerOf<_LoginEvent>(listener)
          ..addListenerOf<_LoginEvent>(listener);

        dispatcher.dispatch(_LoginEvent('u'));
        await _flushMicrotasks();

        expect(callCount, 1);
      });
    });

    test(
      'listeners receive events in the order they were dispatched',
      () async {
        final received = <String>[];
        dispatcher.addListener((e) {
          if (e is _LoginEvent) received.add('login:${e.userId}');
          if (e is _LogoutEvent) received.add('logout');
        });

        dispatcher
          ..dispatch(_LoginEvent('a'))
          ..dispatch(_LogoutEvent())
          ..dispatch(_LoginEvent('b'));
        await _flushMicrotasks();

        expect(received, ['login:a', 'logout', 'login:b']);
      },
    );
  });

  group('DispatcherMixin', () {
    late _TestBus bus;

    setUp(() {
      bus = _TestBus();
    });

    test('dispatch forwards to the underlying dispatcher', () async {
      final received = <_AppEvent>[];
      bus.addListener(received.add);

      final event = _LoginEvent('u');
      bus.dispatch(event);
      await _flushMicrotasks();

      expect(received, [same(event)]);
      expect(bus.dispatcher.lastEvent, same(event));
    });

    test('typed addListener filters by subtype through the mixin', () async {
      final loginEvents = <_LoginEvent>[];
      bus.addListenerOf<_LoginEvent>(loginEvents.add);

      final login = _LoginEvent('u');
      bus
        ..dispatch(_LogoutEvent())
        ..dispatch(login);
      await _flushMicrotasks();

      expect(loginEvents, [same(login)]);
    });

    test('removeListener through the mixin prevents invocation', () async {
      var callCount = 0;
      void listener(_AppEvent _) => callCount++;

      bus
        ..addListener(listener)
        ..removeListener(listener);

      bus.dispatch(_LogoutEvent());
      await _flushMicrotasks();

      expect(callCount, 0);
    });

    test(
      'removeAllListeners through the mixin clears every listener',
      () async {
        var aCalls = 0;
        var bCalls = 0;

        bus
          ..addListener((_) => aCalls++)
          ..addListener((_) => bCalls++)
          ..removeAllListeners();

        bus.dispatch(_LogoutEvent());
        await _flushMicrotasks();

        expect(aCalls, 0);
        expect(bCalls, 0);
      },
    );
  });
}
