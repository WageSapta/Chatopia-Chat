import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetService extends ChangeNotifier {
  StreamSubscription<InternetStatus>? _listen;
  InternetStatus? _internetStatus;

  StreamSubscription<InternetStatus>? get listen => _listen;
  InternetStatus? get internetStatus => _internetStatus;

  StreamSubscription<InternetStatus> listener() {
    return _listen = InternetConnection().onStatusChange.listen((event) {
      _internetStatus = event;
      notifyListeners();
    });
  }
}
