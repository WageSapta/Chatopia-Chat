import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/message_service.dart';
import '../utils/get.dart';

class MessageProvider extends ChangeNotifier {
  final messageService = MessageService();
  final _textController = TextEditingController();
  StreamSubscription<QuerySnapshot>? _subscriptionChats;
  final List<DocumentSnapshot> _messages = [];
  final List<DocumentSnapshot> _unreadMessages = [];
  final int _limit = 200;
  bool _hasMore = false;
  bool _isLoading = false;
  bool _loadingMsg = false;
  bool _friendIsOnline = false;

  bool get friendIsOnline => _friendIsOnline;
  set friendIsOnline(bool val) {
    _friendIsOnline = val;
    notifyListeners();
  }

  bool get hasMore => _hasMore;
  set hasMore(bool val) {
    _hasMore = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool get loadingMsg => _loadingMsg;
  set loadingMsg(bool val) {
    _loadingMsg = val;
    notifyListeners();
  }

  List<DocumentSnapshot> get messages => _messages;
  List<DocumentSnapshot> get unreadMessages => _unreadMessages;

  StreamSubscription<QuerySnapshot>? get subscriptionChats =>
      _subscriptionChats;

  set subscriptionChats(StreamSubscription<QuerySnapshot>? val) {
    _subscriptionChats = val;
    notifyListeners();
  }

  TextEditingController get textController => _textController;

  Future streamOnlineFriend(friendId) async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(friendId)
        .snapshots()
        .listen((value) {
      friendIsOnline = value.get("is_online");
    });
  }

  Future sendMessage(String roomId, String receiverId) async {
    loadingMsg = true;
    try {
      await messageService.sendMessage(
        roomId,
        receiverId,
        _textController.text,
      );
    } on TimeoutException catch (e) {
      Get.fToastShow("Timeout");
      log(e.toString());
    } finally {
      _textController.clear();
      loadingMsg = false;
    }
  }

  Future setInChat({required String roomId, required bool inChat}) async {
    FirebaseFirestore.instance.collection("chat_rooms").doc(roomId).update({
      "in_chat": inChat
          ? FieldValue.arrayUnion([Get.user!.id])
          : FieldValue.arrayRemove([Get.user!.id]),
    });
  }

  subscribeToChatMessages(
      String roomId, String friendId, ScrollController scrollController) async {
    List<DocumentSnapshot> fix = [];
    final myMsgs = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy("timestamp", descending: true);
    subscriptionChats =
        myMsgs.snapshots().listen((QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty && scrollController.hasClients) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            log('New message ${change.doc.get("message")} added');
            if (!change.doc.get("isRead")) {
              _unreadMessages.insert(0, change.doc);
              log("UNREAD MESSAGES : ${_unreadMessages.length}");
            }
            _messages.insert(0, change.doc);
            notifyListeners();
            await FirebaseFirestore.instance
                .collection("chat_rooms")
                .doc(roomId)
                .update({
              "last_message": change.doc.get('message'),
              "last_message_time": FieldValue.serverTimestamp(),
            });
          }
          if (change.type == DocumentChangeType.modified) {
            log('New message ${change.doc.get("message")} modified');
            if (_unreadMessages.isNotEmpty) {
              fix.add(change.doc);
              if (_unreadMessages.length == fix.length) {
                _messages.replaceRange(0, fix.length, fix);
                notifyListeners();
                _unreadMessages.clear();
                fix.clear();
              }
            }
          }
          if (change.type == DocumentChangeType.removed) {
            log('New message ${change.doc.get("message")} removed');
          }
        }
      }
    });
  }

  updateReadMessagesForReceiverId(String roomId, String friendId) async {
    isLoading = true;
    final myMessagesRoom = FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(roomId)
        .collection("messages");
    myMessagesRoom
        .where("isRead", isEqualTo: false)
        .where("receiverId", isEqualTo: Get.user!.id)
        .orderBy("timestamp", descending: true)
        .get()
        .then((value) async {
      for (var e in value.docs) {
        await myMessagesRoom.doc(e.id).update({"isRead": true});
        await FirebaseFirestore.instance
            .collection("users")
            .doc(friendId)
            .update({
          "unread_messages": FieldValue.arrayRemove([e.data()])
        });
      }
    });
  }

  Future getMoreMessages(String roomId, String friendId) async {
    if (_messages.isEmpty) {
      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(roomId)
          .collection("messages")
          .orderBy("timestamp", descending: true)
          .limit(_limit)
          .get()
          .then((value) async {
        List<DocumentSnapshot> unread = value.docs
            .where((element) =>
                element.get("isRead") == false &&
                element.get("receiverId") == friendId)
            .toList();
        _unreadMessages.addAll(unread);
        _messages.addAll(value.docs);
        notifyListeners();
        log("UNREAD MESSAGES : ${_unreadMessages.length}");
      }).whenComplete(() {
        isLoading = false;
      });
    } else {
      QuerySnapshot myMessages =
          await messageService.getMoreMessages(roomId, _messages.last, _limit);
      if (myMessages.docs.isNotEmpty && _messages.length >= _limit) {
        hasMore = true;
        if (_hasMore) {
          _messages.addAll(myMessages.docs);
          notifyListeners();
          if (myMessages.docs.length < _limit) {
            hasMore = false;
          }
        }
      }
    }
  }
}
