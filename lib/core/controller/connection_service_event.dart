sealed class ConnectionServiceEvent {
  const ConnectionServiceEvent();
}

class ConnectionServiceEventChanged extends ConnectionServiceEvent {
  final bool isOffline;

  const ConnectionServiceEventChanged(this.isOffline);
}
