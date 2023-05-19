import 'dart:async';
import 'package:flutter/material.dart';

class DeBouncer {
  final int? seconds;
  VoidCallback? action;
  Timer? _timer;

  DeBouncer({this.seconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(seconds: seconds!), action);
  }
}
