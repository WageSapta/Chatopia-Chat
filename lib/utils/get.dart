import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';
import 'navigator.dart';

class Get with Screen {
  static FToast fToast = FToast();
  static UserModel? user;

  static MediaQueryData mediaQuery = const MediaQueryData();
  static double width = 0.0;
  static double height = 0.0;
  static double blockSizeHorizontal = 0.0;
  static double blockSizeVertical = 0.0;

  static fToastShow(String text, {ToastGravity gravity = ToastGravity.TOP}) {
    fToast.showToast(
      gravity: gravity,
      child: Material(
        shape: const StadiumBorder(),
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static firebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "User not found";
      case "weak-password":
        return "The password provided is too weak";
      case "wrong-password":
        return "Wrong password";
      case "email-already-in-use":
        return "The account already exists for that email";
      case "network-request-failed":
        return "No internet";
      default:
        return e.code;
    }
  }

  static hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void initSizeConfig(BuildContext context) {
    mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;
    blockSizeHorizontal = width / 100;
    blockSizeVertical = height / 100;
  }

  static String setTime({required Timestamp? timestamp, bool isMsg = false}) {
    if (timestamp != null) {
      DateTime now = DateTime.now();
      DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      DateTime lastWeek = DateTime.now().subtract(const Duration(days: 7));
      DateTime dateFriend = timestamp.toDate();
      // tanggal hari ini
      if (isMsg) {
        if (dateFriend.year == now.year &&
            dateFriend.month == now.month &&
            dateFriend.day == now.day) {
          return "Today"; // format Today hanya untuk di messages
        }
      } else {
        if (dateFriend.year == now.year &&
            dateFriend.month == now.month &&
            dateFriend.day == now.day) {
          return DateFormat.Hm()
              .format(dateFriend); // format jam hanya untuk di chats
        }
      }
      // kemarin
      if (dateFriend.year == yesterday.year &&
          dateFriend.month == yesterday.month &&
          dateFriend.day == yesterday.day) {
        return "Yesterday";
      }
      // Kemarin yang lebih dari 24 jam yang lalu
      if (dateFriend.isAfter(lastWeek) &&
          dateFriend.isBefore(DateTime(
              dateFriend.year, dateFriend.month, dateFriend.day + 1))) {
        return DateFormat.EEEE().format(dateFriend); // format hari
      }
      // lebih dari seminggu
      if (now.difference(dateFriend).inDays >= 7) {
        return DateFormat("dd/MM/yy")
            .format(dateFriend); // format hari/bulan/tahun
      }
    }
    return "";
  }

  static setUserDataToLocal(Map<String, dynamic> map) {
    user = UserModel.fromMap(map);
  }

  static snackBar({
    required String text,
    double mBottom = 15,
    double? size,
    Duration duration = const Duration(seconds: 1),
  }) {
    Screen.rootScaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        dismissDirection: DismissDirection.down,
        margin: EdgeInsets.only(
          bottom: mBottom,
          left: 15,
          right: 15,
        ),
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
          style: TextStyle(fontSize: size),
        ),
        duration: duration,
      ),
    );
  }

  static String timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '1 minutes ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      // Jika lebih dari 30 hari, tampilkan tanggal dan bulan dari timestamp
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
