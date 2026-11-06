sealed class InitializeAppResult {
  const InitializeAppResult();
}

class InitializeAppResultSuccess extends InitializeAppResult {
  const InitializeAppResultSuccess();
}

class InitializeAppResultError extends InitializeAppResult {
  final Object error;
  final StackTrace stack;

  const InitializeAppResultError(this.error, this.stack);
}
