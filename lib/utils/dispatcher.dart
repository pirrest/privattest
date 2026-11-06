import 'dart:async';

class Dispatcher<Event> {
  Dispatcher();

  Event? lastEvent;

  final listeners = <Function, void Function(Event event)>{};

  void addListener(void Function(Event event) listener) {
    if (listeners.containsKey(listener)) return;
    listeners[listener] = listener;
  }

  void addListenerOf<E extends Event>(void Function(E event) listener) {
    if (listeners.containsKey(listener)) return;

    void wrapped(Event event) {
      if (event is E) listener(event);
    }

    listeners[listener] = wrapped;
  }

  void removeListener(Function listener) {
    listeners.remove(listener);
  }

  void removeAllListeners() {
    listeners.clear();
  }

  void dispatch(Event event) {
    lastEvent = event;
    // using copy to avoid concurrent modification exception
    final listeners = {...this.listeners};
    scheduleMicrotask(
      () {
        for (final listener in listeners.values) {
          listener(event);
        }
      },
    );
  }
}

mixin DispatcherMixin<Event> {
  Event? get lastEvent => dispatcher.lastEvent;

  set lastEvent(Event? value) {
    dispatcher.lastEvent = value;
  }

  Map<Function, void Function(Event event)> get listeners =>
      dispatcher.listeners;

  final dispatcher = Dispatcher<Event>();

  void addListener(void Function(Event event) listener) {
    dispatcher.addListener(listener);
  }

  void addListenerOf<E extends Event>(void Function(E event) listener) {
    dispatcher.addListenerOf<E>(listener);
  }

  void removeListener(Function listener) {
    dispatcher.removeListener(listener);
  }

  void removeAllListeners() {
    dispatcher.removeAllListeners();
  }

  void dispatch(Event event) {
    dispatcher.dispatch(event);
  }
}
