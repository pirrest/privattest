import 'package:privat_test/core/utils/call_later.dart' as cl;

extension FunctionCallLaterExtension on void Function() {
  void callLater({Duration? delay}) {
    cl.callLater(this, delay: delay);
  }

  void callOnNextFrame() {
    cl.callOnNextFrame(this);
  }
}

extension FutureFunctionCallLaterExtension on Future<dynamic> Function() {
  void callLater({Duration? delay}) {
    cl.callLater(this, delay: delay);
  }

  void callOnNextFrame() {
    cl.callOnNextFrame(this);
  }
}
