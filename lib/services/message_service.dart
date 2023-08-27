import 'dart:async';
import 'package:chatopia/models/message_model.dart';
import 'package:chatopia/utils/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  Future getMoreMessages(
      String roomId, DocumentSnapshot startAfterDocument, int limit) async {
    try {
      return FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(roomId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .startAfterDocument(startAfterDocument)
          .limit(limit)
          .get();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future sendMessage(String roomId, String receiverId, String message) async {
    final myRoom =
        FirebaseFirestore.instance.collection("chat_rooms").doc(roomId);
    bool inChat = await myRoom
        .get()
        .then((value) => (value.get("in_chat") as List).contains(receiverId));

    MessageModel messageModel = MessageModel(
      senderId: Get.user!.id,
      senderEmail: Get.user!.email,
      receiverId: receiverId,
      message: message,
      isRead: inChat ? true : false,
      timestamp: Timestamp.now(),
    );
    if (!inChat) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Get.user!.id)
          .update({
        "unread_messages": FieldValue.arrayUnion([messageModel.toMap()])
      });
    }
    await myRoom
        .collection("messages")
        .add(messageModel.toMap())
        .timeout(const Duration(minutes: 1));
  }
}
