import 'package:privat_test/core/controller/connection_service.dart';
import 'package:privat_test/core/controller/connection_service_event.dart';
import 'package:privat_test/core/utils/my_cubit.dart';

/// Whether the app is offline, for the global offline banner.
class ConnectionCubit extends MyCubit<bool> {
  final ConnectionService _connectionService;

  ConnectionCubit(this._connectionService)
    : super(_connectionService.isOffline) {
    _connectionService.addListenerOf<ConnectionServiceEventChanged>(_onChanged);
  }

  @override
  Future<void> close() {
    _connectionService.removeListener(_onChanged);
    return super.close();
  }

  void _onChanged(ConnectionServiceEventChanged event) {
    emit(event.isOffline);
  }
}
