import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core.dart';

const _endPoint = "https://fcm.googleapis.com/fcm/send";
// static const _endPoint =
//     "https://fcm.googleapis.com/v1/projects/chatopia-834df/messages:send";
final prefs = SharedPreferences.getInstance();
final FirebaseMessaging _fcm = FirebaseMessaging.instance;

Future<String> configJson() async {
  final String response = await rootBundle.loadString('assets/config.json');
  return await jsonDecode(response)['server_key'];
}

class FcmService {
  static String? fcmToken;
  static String? _serverKey;

  static Future<void> init() async {
    _serverKey = await configJson();

    final settings = await _fcm.requestPermission(announcement: true);
    log('User granted notifications permission: ${settings.authorizationStatus}');

    fcmToken = await _fcm.getToken();
    log('FCM Token: $fcmToken');

    // LAUNCH APPLICATION WHEN APP IS TERMINATED
    _fcm.getInitialMessage().then((RemoteMessage? message) async {
      if (message == null) return;
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      log("getInitialMessage: ${message.data['body']} from ${message.data['title']}");
      final data = message.data;
      Screen.pushReplacementNamed(
        Routes.splash,
        arguments: {
          "name": data['name'],
          "profile": data['profile'],
          "room_id": data['room_id'],
          "friend_id": data['friend_id'],
          "push_token": data['push_token'],
        },
      );
    });

    // GET NOTIFICATIONS IN FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (message != null) {
        log('Got a message in the foreground!');
        log("from: ${message.notification!.title}");
        log("messages: ${message.notification!.body}");
      }
    });

    // NOTIFICATION CLICK IN BACKGROUND WHEN APP NOT TERMINATED AKA IN BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('onMessageOpenedApp: ${message.notification!.title.toString()}');
      final data = message.data;
      if (data.containsKey('screen')) {
        Screen.key.currentState
            ?.popUntil((route) => route.settings.name == Routes.chats);
        Screen.toNamed(
          data['screen'],
          arguments: {
            "name": data['name'],
            "profile": data['profile'],
            "room_id": data['room_id'],
            "friend_id": data['friend_id'],
            "push_token": data['push_token'],
          },
        );
      }
    });
  }

  static Future pushNotification(
      {required String token, required Map data}) async {
    try {
      await http.post(
        Uri.parse(_endPoint),
        headers: {
          'Authorization': 'key=$_serverKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "to": token,
          'data': data,
          'notification': {
            "title": data['title'],
            "body": data['body'],
          }
        }),
      );
    } catch (e) {
      log(e.toString());
    }
  }

  static Future saveToken(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"push_token": fcmToken});
    log("saving my push token");
  }

  static Future deleteToken(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"push_token": ""});
    log("delete my push token");
  }
}
