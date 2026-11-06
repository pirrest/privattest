import 'dart:async';

import 'package:flutter/widgets.dart';

void callLater(Function() value, {Duration? delay}) {
  if (delay != null) {
    Future.delayed(delay, value);
  } else {
    unawaited(Future.microtask(value));
  }
}

void callOnNextFrame(Function() value) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    value();
  });
}
