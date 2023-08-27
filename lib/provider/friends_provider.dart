import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../utils/get.dart';

class FriendsProvider extends ChangeNotifier {
  bool _loading = false;
  bool _isSearch = false;
  final List<Map<String, dynamic>> _listFriends = [];
  final List<Map<String, dynamic>> _listSearchFriends = [];
  final _searchController = TextEditingController();

  bool get isSearch => _isSearch;
  bool get loading => _loading;
  TextEditingController get searchController => _searchController;
  List<Map<String, dynamic>> get listFriends => _listFriends;
  List<Map<String, dynamic>> get listSearchFriends => _listSearchFriends;

  set isSearch(bool val) {
    _isSearch = val;
    notifyListeners();
  }

  set loading(bool val) {
    _loading = val;
    notifyListeners();
  }

  Future getFriends() async {
    loading = true;
    try {
      final friends = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('is_friend', isEqualTo: true)
          .where("users", arrayContains: Get.user!.id)
          .get();
      _listFriends.clear();
      for (var e in friends.docs) {
        String friendId =
            (e.get('users') as List).where((e) => e != Get.user!.id).first;
        var friend = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();
        Map<String, dynamic> myMap = UserModel.fromMap(friend.data()!).toMap();
        myMap['room_id'] = e.id;
        _listFriends.add(myMap);
      }
      _listFriends.sort((a, b) => (a["name"] as String).compareTo(b['name']));
    } catch (e) {
      log("$e");
    } finally {
      loading = false;
    }
  }

  search(String e) {
    var results = _listFriends
        .where((element) =>
            element['name'].contains(e) || element['id'].contains(e))
        .toList();
    _listSearchFriends.clear();
    _listSearchFriends.addAll(results);
    notifyListeners();
  }
}
