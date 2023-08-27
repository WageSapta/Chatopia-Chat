import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/get.dart';

class FriendService {
  Future addFriend(String id) async {
    try {
      if (id == Get.user!.id) {
        throw Exception("Is me!");
      }
      var friend =
          await FirebaseFirestore.instance.collection("users").doc(id).get();
      if (friend.data() == null) {
        throw Exception("Friend not found");
      }
      var rooms =
          await FirebaseFirestore.instance.collection("chat_rooms").get();
      for (var e in rooms.docs) {
        if ((e.data()['users'] as List).contains(friend.get('id')) &&
            (e.data()['users'] as List).contains(Get.user!.id)) {
          if (e.data()['is_friend'] == false) {
            throw Exception("Wait for confirmation, check in activity");
          }
          throw Exception("Friend already exist");
        }
      }
      await FirebaseFirestore.instance.collection("chat_rooms").add({
        "users": [Get.user!.id, friend.get('id')],
        "is_friend": false,
        "request_id": Get.user!.id,
        "last_message": null,
        "last_message_time": null,
        "time_created": null,
      }).then((value) {
        FirebaseFirestore.instance
            .collection("chat_rooms")
            .doc(value.id)
            .collection("messages");
      });
    } catch (_) {
      rethrow;
    }
  }
}
