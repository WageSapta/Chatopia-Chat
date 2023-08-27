import 'package:flutter/material.dart';

mixin Screen {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static back() {
    key.currentState?.pop();
  }

  static popToNamed(String name, {Map<String, dynamic>? arguments}) {
    key.currentState?.popAndPushNamed(name, arguments: arguments);
  }

  static pushNamedAndRemoveUntil(String name) {
    key.currentState?.pushNamedAndRemoveUntil(name, (route) => false);
  }

  static Future pushReplacementNamed(String name,
      {Map<String, dynamic>? arguments}) async {
    return key.currentState?.pushReplacementNamed(name, arguments: arguments);
  }

  static toNamed(String name, {Map<String, dynamic>? arguments}) {
    key.currentState?.pushNamed(name, arguments: arguments);
  }
}
