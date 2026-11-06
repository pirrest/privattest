import 'package:privat_test/core/controller/connection_service_event.dart';
import 'package:privat_test/core/utils/dispatcher.dart';

/// Tracks whether the API is reachable, based on the outcome of the requests
/// the app makes. It does not poll: the state changes on the next request.
class ConnectionService extends Dispatcher<ConnectionServiceEvent> {
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  /// A request failed because the server could not be reached.
  void reportFailure() => _update(true);

  /// A request got an answer from the server.
  void reportSuccess() => _update(false);

  void _update(bool isOffline) {
    if (_isOffline == isOffline) return;
    _isOffline = isOffline;
    dispatch(ConnectionServiceEventChanged(isOffline));
  }
}
