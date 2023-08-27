import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  Future<void> deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  Future getUser(String id) async {
    try {
      final user =
          await FirebaseFirestore.instance.collection("users").doc(id).get();
      return user.data()!;
    } catch (e) {
      log(e.toString());
    }
  }

  Future saveUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      log(e.toString());
    }
  }
}
