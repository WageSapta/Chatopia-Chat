import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  Future<void> setIsOnline({required bool isonline}) async {
    var prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? "";
    if (id.isNotEmpty) {
      FirebaseFirestore.instance.collection("users").doc(id).update({
        "is_online": isonline,
        "last_seen": FieldValue.serverTimestamp(),
      });
    }
  }
}
