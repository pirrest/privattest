import 'dart:developer' as dev;

import 'package:watch_it/watch_it.dart';

void log(String message, {String name = ''}) {
  di.maybeGet<LoggerService>()?.log(message, name: name);
}

void error(String message, {required StackTrace stack}) {
  di.maybeGet<LoggerService>()?.error(message, stack: stack);
}

class LoggerService {
  void log(String message, {String name = ''}) {
    dev.log(message, name: name);
  }

  void error(String message, {required StackTrace stack}) {
    dev.log(message, name: 'ERR', stackTrace: stack);
  }
}
